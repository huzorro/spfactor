package main

import (
	"database/sql"
	"encoding/json"
	"flag"
	"github.com/go-martini/martini"
	_ "github.com/go-sql-driver/mysql"
	"github.com/gosexy/redis"
	"github.com/huzorro/spfactor/sexredis"
	//	"io/ioutil"
	"github.com/martini-contrib/render"
	"github.com/martini-contrib/sessions"
	"log"
	"net"
	"net/http"
	"os"
	"strconv"
	"strings"
)

const (
	RESPONSE_OK_TEXT                   = "{\"response\":\"OK\"}"
	RESPONSE_REDIS_NOK_TEXT            = "{\"response\":\"NOK\", \"text\":\"REDIS\"}"
	RESPONSE_JSON_NOK_TEXT             = "{\"response\":\"NOK\", \"text\":\"JSON\"}"
	RESPONSE_PUT_NOK_TEXT              = "{\"response\":\"NOK\", \"text\":\"PUT\"}"
	RESPONSE_RELOAD_NOK_TEXT           = "{\"response\":\"NOK\", \"text\":\"RELOAD\"}"
	RESPONSE_RELOAD_SPINFO_NOK_TEXT    = "{\"response\":\"NOK\", \"text\":\"RELOAD:SPINFO\"}"
	RESPONSE_RELOAD_SPCONSIGN_NOK_TEXT = "{\"response\":\"NOK\", \"text\":\"RELOAD:SPCONSIGN\"}"
	RESPONSE_RELOAD_SPSERVICE_NOK_TEXT = "{\"response\":\"NOK\", \"text\":\"RELOAD:SPSERVICE\"}"
	RESPONSE_RELOAD_SPCP_NOK_TEXT      = "{\"response\":\"NOK\", \"text\":\"RELOAD:SPCP\"}"
	RESPONSE_RELOAD_SPSINK_NOK_TEXT    = "{\"response\":\"NOK\", \"text\":\"RELOAD:SPSINK\"}"
	RESPONSE_RELOAD_SPMSISDN_NOK_TEXT  = "{\"response\":\"NOK\", \"text\":\"RELOAD:SPMSISDN\"}"
	RESPONSE_GET_MO_NOK_TEXT           = "{\"response\":\"NOK\", \"text\":\"GETMO\"}"
	RESPONSE_GET_MT_NOK_TEXT           = "{\"response\":\"NOK\", \"text\":\"GETMT\"}"
)

const (
	MO_RECEIVE_QUEUE_NAME      = "mo:receive:queue"
	MT_RECEIVE_QUEUE_NAME      = "mt:receive:queue"
	ONLY_MT_RECEIVE_QUEUE_NAME = "onlymt:receive:queue"
)
const (
	MO_REST_QUEUE_NAME = "mo:rest:queue"
	MT_REST_QUEUE_NAME = "mt:rest:queue"
)

const (
	RELOAD_CACHE_SPINFO = 1 << iota
	RELOAD_CACHE_SPCONSIGN
	RELOAD_CACHE_SPSERVICE
	RELOAD_CACHE_SPCP
	RELOAD_CACHE_SPMSISDN
	RELOAD_CACHE_SPSINK
)

func controlRoot(r *http.Request, w http.ResponseWriter, log *log.Logger, session sessions.Session, render render.Render, ms []*SpStatMenu) {
	//cross domain
	//	w.Header().Set("Access-Control-Allow-Origin", "*")
	var (
		user SpStatUser
	)
	value := session.Get(SESSION_KEY_QUSER)

	if v, ok := value.([]byte); ok {
		json.Unmarshal(v, &user)
	} else {
		log.Printf("session stroe type error")
		http.Redirect(w, r, ERROR_PAGE_NAME, 301)
		return
	}
	var menu []*SpStatMenu
	for _, elem := range ms {
		if user.Role.Menu&elem.Id == elem.Id {
			menu = append(menu, elem)
		}
	}
	render.HTML(200, menu[0].Name, menu)
}

func controlDefault(r *http.Request, w http.ResponseWriter, log *log.Logger, session sessions.Session, render render.Render, ms []*SpStatMenu) {
	//cross domain
	//	w.Header().Set("Access-Control-Allow-Origin", "*")
	var (
		user SpStatUser
	)
	path := r.URL.Path
	value := session.Get(SESSION_KEY_QUSER)

	if v, ok := value.([]byte); ok {
		json.Unmarshal(v, &user)
	} else {
		log.Printf("session stroe type error")
		http.Redirect(w, r, ERROR_PAGE_NAME, 301)
		return
	}
	var menu []*SpStatMenu

	for _, elem := range ms {
		if (user.Role.Menu & elem.Id) == elem.Id {
			menu = append(menu, elem)
		}
	}
	index := strings.LastIndex(path, "/")
	render.HTML(200, path[index+1:], menu)
}
func logout(r *http.Request, w http.ResponseWriter, log *log.Logger, session sessions.Session) {
	session.Clear()
	http.Redirect(w, r, LOGIN_PAGE_NAME, 301)
}
func rLogin(r *http.Request, w http.ResponseWriter, log *log.Logger, db *sql.DB, session sessions.Session) (int, string) {
	//cross domain
	w.Header().Set("Access-Control-Allow-Origin", "*")
	un := r.PostFormValue("username")
	pd := r.PostFormValue("password")
	var (
		s LoginStatus
	)

	stmtOut, err := db.Prepare("SELECT a.id, a.username, a.password, a.roleid, b.name, b.privilege, b.menu, a.accessid, c.pri_group, c.pri_rule FROM sp_user a " +
		"INNER JOIN sp_role b ON a.roleid = b.id " +
		"INNER JOIN sp_access_privilege c ON a.accessid = c.id " +
		"WHERE username = ? AND password = ? ")
	if err != nil {
		log.Printf("get login user fails %s", err)
		s = LoginStatus{500, "内部错误导致登录失败."}
		rs, _ := json.Marshal(s)
		return http.StatusOK, string(rs)
	}
	result, err := stmtOut.Query(un, pd)
	defer func() {
		stmtOut.Close()
		result.Close()
	}()
	if err != nil {
		log.Printf("%s", err)
		//		http.Redirect(w, r, ERROR_PAGE_NAME, 301)
		s = LoginStatus{500, "内部错误导致登录失败."}
		rs, _ := json.Marshal(s)
		return http.StatusOK, string(rs)
	}
	if result.Next() {
		u := SpStatUser{}
		u.Role = &SpStatRole{}
		u.Access = &SpStatAccess{}
		var g string
		if err := result.Scan(&u.Id, &u.UserName, &u.Password, &u.Role.Id, &u.Role.Name, &u.Role.Privilege, &u.Role.Menu, &u.Access.Id, &g, &u.Access.Rule); err != nil {
			log.Printf("%s", err)
			s = LoginStatus{500, "内部错误导致登录失败."}
			rs, _ := json.Marshal(s)
			return http.StatusOK, string(rs)
		} else {
			u.Access.Group = strings.Split(g, ";")
			//
			uSession, _ := json.Marshal(u)
			session.Set(SESSION_KEY_QUSER, uSession)
			s = LoginStatus{200, "登录成功"}
			rs, _ := json.Marshal(s)
			return http.StatusOK, string(rs)
		}

	} else {
		log.Printf("%s", err)
		s = LoginStatus{403, "登录失败,用户名/密码错误"}
		rs, _ := json.Marshal(s)
		return http.StatusOK, string(rs)
	}

}

func usageRecord(r *http.Request, w http.ResponseWriter, log *log.Logger, db *sql.DB) (int, string) {
	//cross domain
	w.Header().Set("Access-Control-Allow-Origin", "*")

	stime := r.PostFormValue("start_datetime")
	etime := r.PostFormValue("end_datetime")
	terminal := r.PostFormValue("terminal")
	var (
		s LoginStatus
	)
	stmtOut, err := db.Prepare("SELECT spnum, spname, serviceword, servicename, " +
		"servicefee, terminal, consignid, consignname, " +
		"provincename, cityname, statusid, logtime FROM sp_mo_log " +
		"WHERE logtime >= ? AND logtime <= ? AND terminal = ?")
	if err != nil {
		log.Printf("%s", err)
		s = LoginStatus{500, "内部错误导致查询失败."}
		r, _ := json.Marshal(s)
		return http.StatusOK, string(r)
	}
	result, err := stmtOut.Query(stime, etime, terminal)
	if err != nil {
		log.Printf("%s", err)
		s = LoginStatus{500, "内部错误导致查询失败."}
		r, _ := json.Marshal(s)
		return http.StatusOK, string(r)
	}
	var mos []SpUser
	for result.Next() {
		user := SpUser{}
		result.Scan(&user.SpInfo.Spnum, &user.SpInfo.Spname,
			&user.SpService.Serviceword, &user.SpService.Servicename,
			&user.SpService.Servicefee, &user.SpServiceRule.Terminal,
			&user.SpConsign.Consignid, &user.SpConsign.Consignname,
			&user.SpMsisdn.Provincename, &user.SpMsisdn.Cityname, &user.SpServiceRule.Statusid, &user.SpServiceRule.Timeline)
		mos = append(mos, user)
	}

	stmtOutT, err := db.Prepare("SELECT spnum, spname, serviceword, servicename, " +
		"servicefee, terminal, consignid, consignname, " +
		"provincename, cityname, statusid, logtime, expendtime FROM sp_mt_log " +
		"WHERE logtime >= ? AND logtime <= ? AND terminal = ?")
	if err != nil {
		log.Printf("%s", err)
		s = LoginStatus{500, "内部错误导致查询失败."}
		r, _ := json.Marshal(s)
		return http.StatusOK, string(r)
	}
	resultT, err := stmtOutT.Query(stime, etime, terminal)
	if err != nil {
		log.Printf("%s", err)
		s = LoginStatus{500, "内部错误导致查询失败."}
		r, _ := json.Marshal(s)
		return http.StatusOK, string(r)
	}
	var mts []SpUser
	for resultT.Next() {
		user := SpUser{}
		resultT.Scan(&user.SpInfo.Spnum, &user.SpInfo.Spname,
			&user.SpService.Serviceword, &user.SpService.Servicename,
			&user.SpService.Servicefee, &user.SpServiceRule.Terminal,
			&user.SpConsign.Consignid, &user.SpConsign.Consignname,
			&user.SpMsisdn.Provincename, &user.SpMsisdn.Cityname, &user.SpServiceRule.Statusid, &user.SpServiceRule.Timeline, &user.SpServiceRule.Expendtime)
		mts = append(mts, user)
	}

	transaction := struct {
		Mos []SpUser
		Mts []SpUser
	}{mos, mts}

	jsondata, _ := json.Marshal(transaction)
	log.Println(string(jsondata))
	defer func() {
		stmtOut.Close()
		result.Close()
		stmtOutT.Close()
		resultT.Close()
	}()
	return http.StatusOK, string(jsondata)
}
func finaSinkAdu(r *http.Request, w http.ResponseWriter, log *log.Logger, db *sql.DB, session sessions.Session, p martini.Params) (int, string) {
	//cross domain
	w.Header().Set("Access-Control-Allow-Origin", "*")

	stime := r.PostFormValue("start_datetime")
	etime := r.PostFormValue("end_datetime")
	spnum := r.PostFormValue("spnum")
	var (
		s         LoginStatus
		user      SpStatUser
		con       string
		sink      string
		tableName string
	)
	if sink = p["sink"]; sink != "" {
		tableName = "sp_sink_stat"
	} else {
		tableName = "sp_final_stat"
	}

	value := session.Get(SESSION_KEY_QUSER)

	if v, ok := value.([]byte); ok {
		json.Unmarshal(v, &user)
	} else {
		log.Printf("session stroe type error")
		s = LoginStatus{500, "内部错误导致查询失败."}
		r, _ := json.Marshal(s)
		return http.StatusOK, string(r)
	}
	switch user.Access.Rule {
	case GROUP_PRI_ALL:
	case GROUP_PRI_ALLOW:
		con = "AND consignid IN(" + strings.Join(user.Access.Group, ",") + ")"
	case GROUP_PRI_BAN:
		con = "AND consignid NOT IN(" + strings.Join(user.Access.Group, ",") + ")"
	default:
	}

	stmtOut, err := db.Prepare("SELECT serviceid, servicename, SUM(monums), SUM(mousers), SUM(mtnums), SUM(mtusers), SUM(binary fee)/100 FROM " + tableName +
		" WHERE day >= ? AND day <= ? " + con + " AND spnum = ? GROUP BY serviceid")
	if err != nil {
		log.Printf("%s", err)
		s = LoginStatus{500, "内部错误导致查询失败."}
		r, _ := json.Marshal(s)
		return http.StatusOK, string(r)
	}

	result, err := stmtOut.Query(stime, etime, spnum)
	if err != nil {
		log.Printf("session stroe type error")
		s = LoginStatus{500, "内部错误导致查询失败."}
		r, _ := json.Marshal(s)
		return http.StatusOK, string(r)
	}
	st := StatTable{}
	var ss []StatByServiceid
	for result.Next() {
		s := StatByServiceid{}
		s.Data = StatData{}
		result.Scan(&s.Serviceid, &s.Servicename, &s.Data.Monums, &s.Data.Mousers, &s.Data.Mtnums, &s.Data.Mtusers, &s.Data.Fee)
		ss = append(ss, s)
	}
	st.Service = ss
	stmtOutT, err := db.Prepare("SELECT consignid, consignname, SUM(monums), SUM(mousers), SUM(mtnums), SUM(mtusers), SUM(binary fee)/100 FROM " + tableName +
		" WHERE day >= ? AND day <= ? " + con + " AND spnum = ? GROUP BY consignid")

	if err != nil {
		log.Printf("%s", err)
		s = LoginStatus{500, "内部错误导致查询失败."}
		r, _ := json.Marshal(s)
		return http.StatusOK, string(r)
	}

	resultT, err := stmtOutT.Query(stime, etime, spnum)
	if err != nil {
		log.Printf("%s", err)
		s = LoginStatus{500, "内部错误导致查询失败."}
		r, _ := json.Marshal(s)
		return http.StatusOK, string(r)
	}
	var cs []StatByConsignid
	for resultT.Next() {
		c := StatByConsignid{}
		c.Data = StatData{}
		resultT.Scan(&c.Consignid, &c.Consignname, &c.Data.Monums, &c.Data.Mousers, &c.Data.Mtnums, &c.Data.Mtusers, &c.Data.Fee)
		cs = append(cs, c)
	}
	st.Consign = cs

	stmtOutTt, err := db.Prepare("SELECT provinceid, provincename, SUM(monums), SUM(mousers), SUM(mtnums), SUM(mtusers), SUM(binary fee)/100 FROM " + tableName +
		" WHERE day >= ? AND day <= ? " + con + " AND spnum = ? GROUP BY provinceid")

	if err != nil {
		log.Printf("%s", err)
		s = LoginStatus{500, "内部错误导致查询失败."}
		r, _ := json.Marshal(s)
		return http.StatusOK, string(r)
	}

	resultTt, err := stmtOutTt.Query(stime, etime, spnum)
	if err != nil {
		log.Printf("%s", err)
		s = LoginStatus{500, "内部错误导致查询失败."}
		r, _ := json.Marshal(s)
		return http.StatusOK, string(r)
	}
	var ps []StatByProvinceid
	for resultTt.Next() {
		p := StatByProvinceid{}
		p.Data = StatData{}
		resultTt.Scan(&p.Provinceid, &p.Provincename, &p.Data.Monums, &p.Data.Mousers, &p.Data.Mtnums, &p.Data.Mtusers, &p.Data.Fee)
		ps = append(ps, p)
	}
	st.Province = ps
	jsondata, _ := json.Marshal(st)
	log.Println(string(jsondata))
	defer func() {
		stmtOut.Close()
		result.Close()
		stmtOutT.Close()
		resultT.Close()
		stmtOutTt.Close()
		resultTt.Close()
	}()
	return http.StatusOK, string(jsondata)
}

func finalSinkAdmin(r *http.Request, w http.ResponseWriter, log *log.Logger, db *sql.DB, session sessions.Session, p martini.Params) (int, string) {
	//cross domain
	w.Header().Set("Access-Control-Allow-Origin", "*")

	stime := r.PostFormValue("start_datetime")
	etime := r.PostFormValue("end_datetime")
	var (
		s         LoginStatus
		user      SpStatUser
		con       string
		sink      string
		tableName string
	)
	if sink = p["sink"]; sink != "" {
		tableName = "sp_sink_stat"
	} else {
		tableName = "sp_final_stat"
	}
	value := session.Get(SESSION_KEY_QUSER)

	if v, ok := value.([]byte); ok {
		json.Unmarshal(v, &user)
	} else {
		log.Printf("session stroe type error")
		s = LoginStatus{500, "内部错误导致查询失败."}
		r, _ := json.Marshal(s)
		return http.StatusOK, string(r)
	}
	switch user.Access.Rule {
	case GROUP_PRI_ALL:
	case GROUP_PRI_ALLOW:
		con = "AND consignid IN(" + strings.Join(user.Access.Group, ",") + ")"
	case GROUP_PRI_BAN:
		con = "AND consignid NOT IN(" + strings.Join(user.Access.Group, ",") + ")"
	default:
	}
	stmtOut, err := db.Prepare("SELECT spnum, spname, SUM(monums), SUM(mousers), SUM(mtnums), SUM(mtusers), SUM(binary fee)/100 FROM " + tableName +
		" WHERE day >= ? AND day <= ? " + con + " GROUP BY spnum")
	defer stmtOut.Close()
	if err != nil {
		log.Printf("%s", err)
		s = LoginStatus{500, "内部错误导致查询失败."}
		r, _ := json.Marshal(s)
		return http.StatusOK, string(r)
	}

	result, err := stmtOut.Query(stime, etime)
	defer result.Close()
	if err != nil {
		log.Printf("%s", err)
		s = LoginStatus{500, "内部错误导致查询失败."}
		r, _ := json.Marshal(s)
		return http.StatusOK, string(r)
	}

	var sps []StatBySpnum
	for result.Next() {
		s := StatBySpnum{}
		s.Data = StatData{}
		result.Scan(&s.Spnum, &s.Spname, &s.Data.Monums, &s.Data.Mousers, &s.Data.Mtnums, &s.Data.Mtusers, &s.Data.Fee)
		sps = append(sps, s)
	}
	if sps == nil {
		return http.StatusOK, "{}"
	}
	jsondata, _ := json.Marshal(sps)
	log.Println(string(jsondata))
	return http.StatusOK, string(jsondata)
}
func finalUser(r *http.Request, w http.ResponseWriter, log *log.Logger, db *sql.DB, session sessions.Session) (int, string) {
	//cross domain
	w.Header().Set("Access-Control-Allow-Origin", "*")

	stime := r.PostFormValue("start_datetime")
	etime := r.PostFormValue("end_datetime")
	var (
		s    LoginStatus
		user SpStatUser
		con  string
	)
	value := session.Get(SESSION_KEY_QUSER)

	if v, ok := value.([]byte); ok {
		json.Unmarshal(v, &user)
	} else {
		log.Printf("session stroe type error")
		s = LoginStatus{500, "内部错误导致查询失败."}
		r, _ := json.Marshal(s)
		return http.StatusOK, string(r)
	}
	switch user.Access.Rule {
	case GROUP_PRI_ALL:
	case GROUP_PRI_ALLOW:
		con = "AND consignid IN(" + strings.Join(user.Access.Group, ",") + ")"
	case GROUP_PRI_BAN:
		con = "AND consignid NOT IN(" + strings.Join(user.Access.Group, ",") + ")"
	default:
	}
	stmtOut, err := db.Prepare("SELECT serviceid, servicename, SUM(monums), SUM(mousers), SUM(mtnums), SUM(mtusers), SUM(binary fee)/100 FROM sp_final_stat " +
		"WHERE day >= ? AND day <= ? " + con + " GROUP BY serviceid")
	defer stmtOut.Close()
	if err != nil {
		log.Printf("%s", err)
		s = LoginStatus{500, "内部错误导致查询失败."}
		r, _ := json.Marshal(s)
		return http.StatusOK, string(r)
	}

	result, err := stmtOut.Query(stime, etime)
	defer result.Close()
	if err != nil {
		log.Printf("%s", err)
		s = LoginStatus{500, "内部错误导致查询失败."}
		r, _ := json.Marshal(s)
		return http.StatusOK, string(r)
	}
	st := StatTable{}
	var ss []StatByServiceid
	for result.Next() {
		s := StatByServiceid{}
		s.Data = StatData{}
		result.Scan(&s.Serviceid, &s.Servicename, &s.Data.Monums, &s.Data.Mousers, &s.Data.Mtnums, &s.Data.Mtusers, &s.Data.Fee)
		ss = append(ss, s)
	}
	st.Service = ss
	stmtOutT, err := db.Prepare("SELECT consignid, consignname, SUM(monums), SUM(mousers), SUM(mtnums), SUM(mtusers), SUM(binary fee)/100 FROM sp_final_stat " +
		"WHERE day >= ? AND day <= ? " + con + " GROUP BY consignid")
	defer stmtOutT.Close()
	if err != nil {
		log.Printf("%s", err)
		s = LoginStatus{500, "内部错误导致查询失败."}
		r, _ := json.Marshal(s)
		return http.StatusOK, string(r)
	}

	resultT, err := stmtOut.Query(stime, etime)
	defer resultT.Close()
	if err != nil {
		log.Printf("%s", err)
		s = LoginStatus{500, "内部错误导致查询失败."}
		r, _ := json.Marshal(s)
		return http.StatusOK, string(r)
	}
	var cs []StatByConsignid
	for resultT.Next() {
		c := StatByConsignid{}
		c.Data = StatData{}
		resultT.Scan(&c.Consignid, &c.Consignname, &c.Data.Monums, &c.Data.Mousers, &c.Data.Mtnums, &c.Data.Mtusers, &c.Data.Fee)
		cs = append(cs, c)
	}
	st.Consign = cs

	stmtOutTt, err := db.Prepare("SELECT provinceid, provincename, SUM(monums), SUM(mousers), SUM(mtnums), SUM(mtusers), SUM(binary fee)/100 FROM sp_final_stat " +
		"WHERE day >= ? AND day <= ? " + con + " GROUP BY provinceid")
	defer stmtOutTt.Close()
	if err != nil {
		log.Printf("%s", err)
		s = LoginStatus{500, "内部错误导致查询失败."}
		r, _ := json.Marshal(s)
		return http.StatusOK, string(r)
	}

	resultTt, err := stmtOut.Query(stime, etime)
	defer resultTt.Close()
	if err != nil {
		log.Printf("%s", err)
		s = LoginStatus{500, "内部错误导致查询失败."}
		r, _ := json.Marshal(s)
		return http.StatusOK, string(r)
	}
	var ps []StatByProvinceid
	for resultTt.Next() {
		p := StatByProvinceid{}
		p.Data = StatData{}
		resultTt.Scan(&p.Provinceid, &p.Provincename, &p.Data.Monums, &p.Data.Mousers, &p.Data.Mtnums, &p.Data.Mtusers, &p.Data.Fee)
		ps = append(ps, p)
	}
	st.Province = ps
	jsondata, _ := json.Marshal(st)
	return http.StatusOK, string(jsondata)
}

func moReceiver(r *http.Request, w http.ResponseWriter, log *log.Logger, redisPool *sexredis.RedisPool) (int, string) {
	rc, err := redisPool.Get()
	if err != nil {
		return http.StatusInternalServerError, RESPONSE_REDIS_NOK_TEXT
	}
	defer func() {
		r.Body.Close()
		redisPool.Close(rc)
	}()
	queue := sexredis.New()
	queue.SetRClient(MO_RECEIVE_QUEUE_NAME, rc)
	rv := r.URL.Query()
	rip, _, _ := net.SplitHostPort(r.RemoteAddr)
	//	realIp := r.Header.Get("X-FORWARDED-FOR")
	rv.Add("rip", rip)

	moJson, err := json.Marshal(rv)
	log.Printf("receive mo %s", string(moJson))

	if err != nil {
		log.Printf("json marshal fails %s", err)
		return http.StatusInternalServerError, RESPONSE_JSON_NOK_TEXT
	}
	if _, err := queue.Put(moJson); err != nil {
		log.Printf("put receive mo into queue fails %s", err)
		return http.StatusInternalServerError, RESPONSE_PUT_NOK_TEXT
	}
	return http.StatusOK, RESPONSE_OK_TEXT
}

func mtReceiver(r *http.Request, w http.ResponseWriter, log *log.Logger, redisPool *sexredis.RedisPool) (int, string) {
	rc, err := redisPool.Get()
	if err != nil {
		return http.StatusInternalServerError, RESPONSE_REDIS_NOK_TEXT
	}
	defer func() {
		r.Body.Close()
		redisPool.Close(rc)
	}()
	queue := sexredis.New()
	queue.SetRClient(MT_RECEIVE_QUEUE_NAME, rc)

	rv := r.URL.Query()
	rip, _, _ := net.SplitHostPort(r.RemoteAddr)
	//	realIp := r.Header.Get("X-FORWARDED-FOR")
	rv.Add("rip", rip)

	mtJson, err := json.Marshal(rv)
	log.Printf("receive mt %s", string(mtJson))

	if err != nil {
		log.Printf("json marshal fails %s", err)
		return http.StatusInternalServerError, RESPONSE_JSON_NOK_TEXT
	}
	if _, err := queue.Put(mtJson); err != nil {
		log.Printf("put receive mt into queue fails %s", err)
		return http.StatusInternalServerError, RESPONSE_PUT_NOK_TEXT
	}
	return http.StatusOK, RESPONSE_OK_TEXT
}
func onlyMtReceiver(r *http.Request, w http.ResponseWriter, log *log.Logger, redisPool *sexredis.RedisPool) (int, string) {
	rc, err := redisPool.Get()
	if err != nil {
		return http.StatusInternalServerError, RESPONSE_REDIS_NOK_TEXT
	}
	defer func() {
		r.Body.Close()
		redisPool.Close(rc)
	}()
	queue := sexredis.New()
	queue.SetRClient(ONLY_MT_RECEIVE_QUEUE_NAME, rc)

	rv := r.URL.Query()
	rip, _, _ := net.SplitHostPort(r.RemoteAddr)
	//	realIp := r.Header.Get("X-FORWARDED-FOR")
	rv.Add("rip", rip)

	mtJson, err := json.Marshal(rv)
	log.Printf("only receive mt %s", string(mtJson))

	if err != nil {
		log.Printf("json marshal fails %s", err)
		return http.StatusInternalServerError, RESPONSE_JSON_NOK_TEXT
	}
	if _, err := queue.Put(mtJson); err != nil {
		log.Printf("put only receive mt into queue fails %s", err)
		return http.StatusInternalServerError, RESPONSE_PUT_NOK_TEXT
	}
	return http.StatusOK, RESPONSE_OK_TEXT
}

func cacheLoad(r *http.Request, w http.ResponseWriter, log *log.Logger, cache *Cache, p martini.Params) (int, string) {
	log.Printf("receive reload params [%s]", p["c"])
	defer r.Body.Close()
	if _, ok := p["c"]; !ok {
		log.Printf("invalid params")
		return http.StatusOK, RESPONSE_RELOAD_NOK_TEXT
	}
	c, err := strconv.Atoi(p["c"])
	if err != nil {
		log.Printf("invalid params %s", err)
		return http.StatusOK, RESPONSE_RELOAD_NOK_TEXT
	}

	if (c & RELOAD_CACHE_SPINFO) == RELOAD_CACHE_SPINFO {
		if err := cache.SetSpInfo(); err != nil {
			log.Printf("sp_info load fails %s", err)
			return http.StatusOK, RESPONSE_RELOAD_SPINFO_NOK_TEXT
		}
		log.Println("sp_info load ...")
	}
	if (c & RELOAD_CACHE_SPCONSIGN) == RELOAD_CACHE_SPCONSIGN {
		if err := cache.SetSpConsign(); err != nil {
			log.Printf("sp_consign load fails %s", err)
			return http.StatusOK, RESPONSE_RELOAD_SPCONSIGN_NOK_TEXT
		}
		log.Println("sp_consign load ...")
	}
	if (c & RELOAD_CACHE_SPSERVICE) == RELOAD_CACHE_SPSERVICE {
		if err := cache.SetSpService(); err != nil {
			log.Printf("sp_service load fails %s", err)
			return http.StatusOK, RESPONSE_RELOAD_SPSERVICE_NOK_TEXT
		}
		log.Println("sp_service load ...")
	}

	if (c & RELOAD_CACHE_SPCP) == RELOAD_CACHE_SPCP {
		if err := cache.SetSpCp(); err != nil {
			log.Printf("sp_cp load fails %s", err)
			return http.StatusOK, RESPONSE_RELOAD_SPCP_NOK_TEXT
		}
		log.Println("sp_cp load ...")
	}
	if (c & RELOAD_CACHE_SPSINK) == RELOAD_CACHE_SPSINK {
		if err := cache.SetSpSink(); err != nil {
			log.Printf("sp_sink load fails %s", err)
			return http.StatusOK, RESPONSE_RELOAD_SPSINK_NOK_TEXT
		}
		log.Println("sp_sink load ...")
	}

	if (c & RELOAD_CACHE_SPMSISDN) == RELOAD_CACHE_SPMSISDN {
		if err := cache.SetSpMsisdn(); err != nil {
			log.Printf("sp_msisdn load fails %s", err)
			return http.StatusOK, RESPONSE_RELOAD_SPMSISDN_NOK_TEXT
		}
		log.Println("sp_msisdn load ...")
	}

	return http.StatusOK, RESPONSE_OK_TEXT
}

func getMo(r *http.Request, w http.ResponseWriter, log *log.Logger, redisPool *sexredis.RedisPool, p martini.Params) (int, string) {
	log.Printf("receive ids params [%s]", p["ids"])
	if _, ok := p["ids"]; !ok {
		log.Printf("invalid params")
		return http.StatusOK, RESPONSE_GET_MO_NOK_TEXT
	}

	rc, err := redisPool.Get()
	if err != nil {
		log.Printf("get redis connection of pool fails %s", err)
		return http.StatusInternalServerError, RESPONSE_GET_MO_NOK_TEXT
	}
	defer func() {
		r.Body.Close()
		redisPool.Close(rc)
	}()
	queue := sexredis.New()
	queue.SetRClient(MO_REST_QUEUE_NAME+":"+p["ids"], rc)
	msg := queue.Get(false, 0)
	if msg.Err != nil {
		log.Printf("get mo fails %s", msg.Err)
		return http.StatusInternalServerError, RESPONSE_GET_MO_NOK_TEXT
	}

	//msg type ok ?
	var (
		mo string
		ok bool
	)
	if mo, ok = msg.Content.(string); !ok {
		log.Printf("msg type error")
		return http.StatusInternalServerError, RESPONSE_GET_MO_NOK_TEXT
	}
	return http.StatusOK, mo
}

func getMt(r *http.Request, w http.ResponseWriter, log *log.Logger, redisPool *sexredis.RedisPool, p martini.Params) (int, string) {
	log.Printf("receive ids params [%s]", p["ids"])
	if _, ok := p["ids"]; !ok {
		log.Printf("invalid params")
		return http.StatusOK, RESPONSE_GET_MT_NOK_TEXT
	}

	rc, err := redisPool.Get()
	if err != nil {
		log.Printf("get redis connection of pool fails %s", err)
		return http.StatusInternalServerError, RESPONSE_GET_MT_NOK_TEXT
	}
	defer func() {
		r.Body.Close()
		redisPool.Close(rc)
	}()
	queue := sexredis.New()
	queue.SetRClient(MT_REST_QUEUE_NAME+":"+p["ids"], rc)
	msg := queue.Get(false, 0)
	if msg.Err != nil {
		log.Printf("get mo fails %s", msg.Err)
		return http.StatusInternalServerError, RESPONSE_GET_MT_NOK_TEXT
	}
	//msg type ok ?
	var (
		mt string
		ok bool
	)
	if mt, ok = msg.Content.(string); !ok {
		log.Printf("msg type error")
		return http.StatusInternalServerError, RESPONSE_GET_MO_NOK_TEXT
	}
	return http.StatusOK, mt
}

func main() {
	//run moReceiver, mtReceiver, cache, moRest, mtRest, moHandler, mtHandler, onlyMtReceiver, onlyMtHandler
	//receiver
	moReceiverPtr := flag.Bool("moReceiver", false, "mo receiver start")
	mtReceiverPtr := flag.Bool("mtReceiver", false, "mt recevier start")
	onlyMtReceiverPtr := flag.Bool("onlyMtReceiver", false, "only receiver mt")
	//rest api for sync data
	moRestPtr := flag.Bool("moRest", false, "mo rest start")
	mtRestPtr := flag.Bool("mtRest", false, "mt rest start")
	//cache config data
	cachePtr := flag.Bool("cache", false, "cache start")
	//handler msg
	moHandlerPtr := flag.Bool("moHandler", false, "mo handler start")
	mtHandlerPtr := flag.Bool("mtHandler", false, "mt handler start")
	onlyMtHandlerPtr := flag.Bool("onlyMtHandler", false, "only handler mt start")

	//stat
	finalStatPtr := flag.Bool("finalStat", false, "final stat start")

	portPtr := flag.String("port", ":10086", "service port")

	redisIdlePtr := flag.Int("redis", 20, "redis idle connections")
	dbMaxPtr := flag.Int("db", 10, "max db open connections")

	flag.Parse()

	logger := log.New(os.Stdout, "\r\n", log.Ldate|log.Ltime|log.Lshortfile)
	redisPool := &sexredis.RedisPool{make(chan *redis.Client, *redisIdlePtr), func() (*redis.Client, error) {
		client := redis.New()
		err := client.Connect("localhost", uint(6379))
		return client, err
	}}
	db, err := sql.Open("mysql", "sp:woai840511~@tcp(127.0.0.1:3306)/sp?charset=utf8")
	db.SetMaxOpenConns(*dbMaxPtr)

	if err != nil {
		panic(err.Error()) // Just for example purpose. You should use proper error handling instead of panic
	}

	cache := New()
	cache.SetRedisConnect(redisPool)
	cache.SetMysqlConnect(db)

	mtn := martini.Classic()

	mtn.Map(logger)
	mtn.Map(redisPool)
	mtn.Map(db)

	mtn.Map(cache)

	//	load rbac node
	if nMap, err := cache.RbacNodeToMap(); err != nil {
		logger.Printf("rbac node to map fails %s", err)
	} else {
		mtn.Map(nMap)
	}
	//load rbac menu
	if ms, err := cache.RbacMenuToSlice(); err != nil {
		logger.Printf("rbac menu to slice fails %s", err)
	} else {
		mtn.Map(ms)
	}
	//session
	store := sessions.NewCookieStore([]byte("secret123"))
	mtn.Use(sessions.Sessions("Qsession", store))
	//render
	rOptions := render.Options{}
	rOptions.Extensions = []string{".tmpl", ".html"}
	mtn.Use(render.Renderer(rOptions))

	if *moReceiverPtr {
		mtn.Get("/moReceiver", moReceiver)
	}
	if *mtReceiverPtr {
		mtn.Get("/mtReceiver", mtReceiver)
	}
	if *onlyMtReceiverPtr {
		mtn.Get("/omtReceiver", onlyMtReceiver)
	}
	if *cachePtr {
		mtn.Get("/cache/:c", cacheLoad)
	}
	if *moRestPtr {
		mtn.Get("/restApi/mo/:ids", getMo)
	}
	if *mtRestPtr {
		mtn.Get("/restApi/mt/:ids", getMt)
	}

	if *finalStatPtr {
		//rbac filter
		rbac := &RBAC{}
		mtn.Use(rbac.Filter())

		mtn.Get("/login", func(r render.Render) {
			r.HTML(200, "login", "")
		})
		mtn.Get("/logout", logout)
		//restful api
		//return json
		mtn.Post("/rLogin", rLogin)
		mtn.Post("/user", finalUser)
		mtn.Post("/fs/admin", finalSinkAdmin)
		mtn.Post("/fs/admin/:sink", finalSinkAdmin)
		mtn.Post("/fs/adu", finaSinkAdu)
		mtn.Post("/fs/adu/:sink", finaSinkAdu)
		mtn.Post("/ur", usageRecord)
		//control
		mtn.Get("/admin", controlDefault)
		mtn.Get("/common", controlDefault)
		mtn.Get("/sink", controlDefault)
		mtn.Get("/service", controlDefault)
		mtn.Get("/", controlRoot)
		//	mtn.Get("/service", func() string {
		//		return "OK"
		//	})
	}

	if *moReceiverPtr || *mtReceiverPtr || *onlyMtReceiverPtr || *cachePtr || *moRestPtr || *mtRestPtr || *finalStatPtr {
		go http.ListenAndServe(*portPtr, mtn)
	}

	if *moHandlerPtr {
		rc, err := redisPool.Get()
		if err != nil {
			log.Printf("get redis connection fails %s", err)
			return
		}

		defer redisPool.Close(rc)

		queue := sexredis.New()
		queue.SetRClient(MO_RECEIVE_QUEUE_NAME, rc)
		queue.Worker(2, true, &StoreMsg{db}, &IpToRule{cache}, &MatchArea{cache},
			&MatchWord{cache}, &CacheMo{cache}, &UpdateMoUsers{cache}, &StoreMo{db},
			&FinalMoStat{db, cache}, &MoQueue{redisPool})
	}

	if *mtHandlerPtr {
		rc, err := redisPool.Get()
		if err != nil {
			log.Printf("get redis connection fails %s", err)
			return
		}
		defer redisPool.Close(rc)
		queue := sexredis.New()
		queue.SetRClient(MT_RECEIVE_QUEUE_NAME, rc)
		queue.Worker(2, true, &StoreMsg{db}, &IpToRule{cache}, &MatchMo{cache},
			&SinkReport{cache}, &UpdateMtUsers{cache}, &StoreMt{db}, &FinalMtStat{db, cache},
			&SinkMtStat{db, cache}, &MtQueue{redisPool})
	}

	if *onlyMtHandlerPtr {
		rc, err := redisPool.Get()
		if err != nil {
			log.Printf("get redis connection fails %s", err)
			return
		}
		defer redisPool.Close(rc)
		queue := sexredis.New()
		queue.SetRClient(ONLY_MT_RECEIVE_QUEUE_NAME, rc)
		queue.Worker(2, true, &StoreMsg{db}, &IpToRule{cache}, &MatchArea{cache},
			&MatchWord{cache}, &OnlyMtReport{}, &SinkReport{cache}, &UpdateMtUsers{cache}, &StoreMt{db}, &FinalMtStat{db, cache},
			&SinkMtStat{db, cache}, &MtQueue{redisPool})
	}
	// mtn.Run()
	done := make(chan bool)
	<-done
}

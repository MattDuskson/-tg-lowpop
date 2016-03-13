	// MySQL configuration

var/sqladdress = "localhost"
var/sqlport = "3306"
var/sqlfdbkdb = "hispanistation_server"
var/sqlfdbklogin = "hispanistation"
var/sqlfdbkpass = "FeRi334455"
var/sqlfdbktableprefix = "" //backwords compatibility with downstream server hosts

//Database connections
//A connection is established on world creation. Ideally, the connection dies when the server restarts (After feedback logging.).
var/DBConnection/dbcon = new()	//Feedback database (New database)

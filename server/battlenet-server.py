
import tornado.httpserver
import tornado.ioloop
import tornado.web
import tornado.escape
import tornado.gen
import tornado.httpclient
import math
#import requests
import motor
import datetime

from tornado.options import define, options

define("port", default=8080, type=int)
# define("mysql_host", default="172.16.102.177:3306")
# define("mysql_database", default="feature_db")
# define("mysql_user", default="root")
# define("mysql_password", default="admin")

MONGO_DB_URL = "mongodb://localhost:27017"

RESP_NUM = 50

EARTH_RADIUS = 6378.137
SEARCH_RADIUS = 0.01

class Application(tornado.web.Application):
    def __init__(self):
        handlers = [
                    (r"/user/create", CreateUserHandler),
                    (r"/user/login", LoginHandler),
                    (r"/user/([0-9]+)", UserHandler),
                    (r"/user/avatar", AvatarHandler),
                    #(r"/traffic/feeds", FetchUserTrafficInfoHandler),
                    #(r"/traffic/seen", TrafficViewHandler),
                    #(r"/traffic/image", ImageHandler)
                    ]
        tornado.web.Application.__init__(self, handlers)
        self.db = motor.MotorClient(MONGO_DB_URL).battlenet_database

class BaseHandler(tornado.web.RequestHandler):
    @property
    def db(self):
        return self.application.db

class AvatarHandler(BaseHandler):
    @tornado.web.asynchronous
    @tornado.gen.coroutine
    def get(self):
        user_id = self.get_argument("user_id", "")
        print 'Get Avatar, user_id:' + user_id
        user_avatar = yield self.db.user_avatar.find_one({"user_id":user_id})
        self.set_header("Content-Type", "application/json")
        if user_avatar == None:
            result = '{"result":"avatar_not_exist"}'
        else:
            result = '{"result":"succeeded", "avatar":"%s"}' % (user_avatar["avatar"])
        print result
        self.write(result)
        self.finish

class LoginHandler(BaseHandler):
    @tornado.web.asynchronous
    @tornado.gen.coroutine
    def post(self):
        print 'Got Login request'
        json = tornado.escape.json_decode(self.request.body)
        user = yield self.db.user.find_one({"email":json["email"]})
        self.set_header("Content-Type", "application/json")
        if (user == None):
            self.write('{"result":"account_not_exist"}')
        else:
            if user["password"] == json["password"]:
                print user
                result = '{"result":"succeeded", "user":{"uid":"%s", "email":"%s", "name":"%s", "has_avatar":%d, "password":"%s", "gender":%d, "birth":"%s", "foot":%d, "position":%d, "create_time":"%s"}}' % (str(user["_id"]), user["email"], user["name"], user["has_avatar"], user["password"], user["gender"], str(user["birth"]), user["foot"], user["position"], str(user["create_time"]))
                self.write(result)
            else:
                self.write('{"result":"wrong_password"}')
        self.finish()

class UserHandler(BaseHandler):
    @tornado.web.asynchronous
    @tornado.gen.coroutine
    def get(self):
        print 'get user'

class CreateUserHandler(BaseHandler):
    @tornado.web.asynchronous
    @tornado.gen.coroutine
    def post(self):
        print 'Got signup request'
        json = tornado.escape.json_decode(self.request.body)
        has_avatar = json["avatar"] != "";
        user = yield self.db.user.find_one({"email":json["email"]})
        if user == None:
            try:
                id = yield self.db.user.insert({"email":json["email"],"password":json["password"], "name":json["name"], "gender":json["gender"], "birth":json["birth"], "foot":json["foot"], "position":json["position"],"has_avatar":has_avatar, "invalid":0, "create_time":datetime.datetime.now()})
            except Exception, error:
                print error
                result = '{"result":"server_error"}';

            if id != None:
                result = '{"result":"succeeded","uid":"' + str(id) + '"}'
                if has_avatar:
                    yield self.db.user_avatar.insert({"user_id":str(id), "avatar":json["avatar"]})
        else:
            result = '{"result":"duplicated_email"}'

        self.set_header("Content-Type", "application/json")
        self.write(result)
        self.finish()

class FetchUserTrafficInfoHandler(BaseHandler):
    DEFAULT = "default"
    OLDER = "older"
    LATEST = "latest"
    @tornado.web.asynchronous
    @tornado.gen.coroutine
    def get(self):
        lat = self.get_argument("lat", FetchUserTrafficInfoHandler.DEFAULT)
        lon = self.get_argument("lon", FetchUserTrafficInfoHandler.DEFAULT)
        user_id = self.get_argument("user_id", FetchUserTrafficInfoHandler.DEFAULT)
        time = self.get_argument("time", FetchUserTrafficInfoHandler.DEFAULT)
        direction = self.get_argument("direction", FetchUserTrafficInfoHandler.DEFAULT)
        resp = {}
        info_list = []
        # user_traffic_infos = self.db.query("select * from user_traffic_info where user_id=%s", user_id)
        # print self.db.traffic_info.traffic_info.find({"user_id":user_id})
        if lat != FetchUserTrafficInfoHandler.DEFAULT and lat != "" and lon != FetchUserTrafficInfoHandler.DEFAULT and lon != "":
            for info in (yield motor.Op(self.db.traffic_info.traffic_info.find().sort([("report_time",-1)]).limit(RESP_NUM).to_list)):
                if info["lat"] == '' and info["lon"] == '':
                    break
                distance = count_distance(float(lat), float(lon), float(info["lat"]), float(info["lon"]))
                if(distance <= SEARCH_RADIUS):
                    detail = {}
                    parse_resp(info, detail)
                    info_list.append(detail)
            resp["status"] = "success"
            resp["info"] = info_list
        else:
            if time != FetchUserTrafficInfoHandler.DEFAULT and int(time) > 0 and direction != FetchUserTrafficInfoHandler.DEFAULT and direction != "":
                if direction == FetchUserTrafficInfoHandler.LATEST:
                    for info in (yield motor.Op(self.db.traffic_info.traffic_info.find({"user_id":user_id,"report_time":{"$gt":int(time)}}).sort([("report_time",-1)]).limit(RESP_NUM).to_list)):
                        detail = {}
                        parse_resp(info, detail)
                        info_list.append(detail)
                    resp["status"] = "success"
                    resp["info"] = info_list
                elif direction == FetchUserTrafficInfoHandler.OLDER:
                    for info in (yield motor.Op(self.db.traffic_info.traffic_info.find({"user_id":user_id,"report_time":{"$lt":int(time)}}).sort([("report_time",-1)]).limit(RESP_NUM).to_list)):
                        detail = {}
                        parse_resp(info, detail)
                        info_list.append(detail)
                    resp["status"] = "success"
                    resp["info"] = info_list
                else:
                    resp["status"] = "fail"
            else:
                for info in (yield motor.Op(self.db.traffic_info.traffic_info.find({"user_id":user_id}).sort([("report_time",-1)]).limit(RESP_NUM).to_list)):
                    detail = {}
                    parse_resp(info, detail)
                    # rgc_resp = requests.get("https://avengers.telenav.com/entity/v1/search/json?query={!V1}%20{%22rgc_search_query%22:{%22location%22:{%22lat%22:" + info["lat"] + ",%22lon%22:" + info["lon"] + "}}}&offset=0&limit=1&geo_source=TomTom&entity_source=Telenav")
                    # json = tornado.escape.json_decode(rgc_resp.text)
                    info_list.append(detail)
                resp["status"] = "success"
                resp["info"] = info_list
        self.write(resp)
        self.finish()

class TrafficViewHandler(BaseHandler):
    @tornado.web.asynchronous
    @tornado.gen.coroutine
    def post(self):
        print self.request.body
        json = tornado.escape.json_decode(self.request.body)
        lat = json["lat"]
        lon = json["lon"]
        download_user = json["download_user"]
        # user_traffic_infos = self.db.query("select * from user_traffic_info")
        for info in (yield motor.Op(self.db.traffic_info.traffic_info.find().to_list)):
            if info["lat"] == '' and info["lon"] == '':
                continue
            distance = count_distance(float(lat), float(lon), float(info["lat"]), float(info["lon"]))
            if(distance <= SEARCH_RADIUS):
                query_string = ""
                if (type(info["download_user"]) == type(None)):
                    query_string = download_user + "|"
                else:
                    query_string = info["download_user"] + download_user + "|"
                # self.db.execute("update user_traffic_info set download_times=%s, download_user=%s where id=%s", str(int(info["download_times"]) + 1), query_string, info["id"])
                yield motor.Op(self.db.traffic_info.traffic_info.update, {"_id":info["_id"]},{"$set":{"download_times":str(int(info["download_times"]) + 1),"download_user":query_string}})
        resp = {}
        resp["status"] = "success"
        self.write(resp)
        self.finish()

class ImageHandler(BaseHandler):
    @tornado.web.asynchronous
    @tornado.gen.coroutine
    def get(self):
        image_id = self.get_argument("image_id")
        # images = self.db.query("select * from image where image_id=%s", image_id)
        images = yield motor.Op(self.db.image.image.find({"image_id":image_id}).to_list)
        resp = {}
        for image in images:
            if image["image"] != '':
                resp["image"] = image["image"]
        resp["status"] = "success"
        self.write(resp)
        self.finish()

def rad(d):
    return d * math.pi / 180.0

def count_distance(sLat, sLon, eLat, eLon):
    dLat = rad(sLat) - rad(eLat)
    dLon = rad(sLon) - rad(eLon)
    distance = 2 * math.asin(math.sqrt(math.pow(math.sin(dLat/2),2) + math.cos(rad(sLat)) * math.cos(rad(eLat)) * math.pow(math.sin(dLon/2),2)))
    return distance * EARTH_RADIUS

def parse_resp(resp_from_db, resp):
    if resp_from_db.has_key("lat") and resp_from_db["lat"] != '':
        resp["lat"] = resp_from_db["lat"]
    if resp_from_db.has_key("lon") and resp_from_db["lon"] != '':
        resp["lon"] = resp_from_db["lon"]
    if resp_from_db.has_key("image_id") and resp_from_db["image_id"] != '':
        resp["image_id"] = resp_from_db["image_id"]
    if resp_from_db.has_key("comment") and resp_from_db["comment"] != '':
        resp["comment"] = resp_from_db["comment"]
    if resp_from_db.has_key("user_name") and resp_from_db["user_name"] != '':
        resp["user_name"] = resp_from_db["user_name"]
    if resp_from_db.has_key("incident_type") and resp_from_db["incident_type"] != '':
        resp["incident_type"] = resp_from_db["incident_type"]
    if resp_from_db.has_key("report_time") and resp_from_db["report_time"] != 0:
        resp["report_time"] = resp_from_db["report_time"]
    if resp_from_db.has_key("address") and resp_from_db["address"] != '':
        resp["address"] = resp_from_db["address"]
    if (type(resp_from_db["download_user"]) != type(None)) and resp_from_db["download_user"] != '':
        download_user_list = []
        for user in list(set(resp_from_db["download_user"].rstrip("|").split("|"))):
            download_user = {}
            download_user["name"] = user
            download_user_list.append(download_user)
        resp["download_user"] = download_user_list

#class MotorConnection():
#    @tornado.gen.coroutine
#    def motor_connect(self):
#        db = motor.MotorClient('172.16.102.178',27017).open_sync()
# for info in (yield motor.Op(db.traffic_info.traffic_info.find().to_list)):
#     print info
# tornado.ioloop.IOLoop.instance().stop()

if __name__ == '__main__':
    # file = open("d:\\toogler.png", "rb")
    # data = file.read()
    # print(base64.b64encode(data))
    # file = file("d:\\test.png", "wb")
    # file.write(base64.b64decode("iVBORw0KGgoAAAANSUhEUgAAAHkAAACSCAYAAABheWUIAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyRpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNiAoTWFjaW50b3NoKSIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDo5N0IzNTUxMjMzQTgxMUUzODFGNThENUU5Nzg2RjJEMiIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDpFMzlBRTQ5ODM0MzExMUUzODFGNThENUU5Nzg2RjJEMiI+IDx4bXBNTTpEZXJpdmVkRnJvbSBzdFJlZjppbnN0YW5jZUlEPSJ4bXAuaWlkOjk3QjM1NTEwMzNBODExRTM4MUY1OEQ1RTk3ODZGMkQyIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjk3QjM1NTExMzNBODExRTM4MUY1OEQ1RTk3ODZGMkQyIi8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+1+prPwAAHk1JREFUeNrsnQmY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"))
    # file.close()
    # print time.time();
    # MotorConnection().motor_connect()
    http_server = tornado.httpserver.HTTPServer(Application())
    http_server.listen(options.port)
    print "Server started..."
    tornado.ioloop.IOLoop.instance().start()
    print "Server stopped."



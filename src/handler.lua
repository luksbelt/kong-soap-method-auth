local BasePlugin = require "kong.plugins.base_plugin"
local pl_file = require "pl.file"
local xpath = require "luaxpath"
local lxp = require "lxp"
local lom = require "lxp.lom"

local concat = table.concat
local kong = kong
local ngx = ngx

local soap_1_1 = "http://schemas.xmlsoap.org/soap/envelope/"
local soap_1_2 = "http://www.w3.org/2003/05/soap-envelope"

local SoapMethodAuth = BasePlugin:extend()


local function readFromFile(file_location)
  local content, err = pl_file.read(file_location)
  if not content or err then
    ngx.log(ngx.ERR, "Could not read file contents", err)
    return nil, err
  end

  return content
end


function SoapMethodAuth:new()
  SoapMethodAuth.super.new(self, "soap-method-auth")
end

function SoapMethodAuth:access(conf)
  SoapMethodAuth.super.access(self)

  ngx.req.read_body()
  local xml,err = kong.request.get_raw_body()
  if err then
    ngx.log(ngx.ERR,"error at reading the body message",err)
    xml = readFromFile(ngx.req.get_body_file())
  end

  if (xml == nil or xml == '') and (kong.request.get_method() == "GET") then
    return
  end

  local current_consumer_method = nil

  local consumer =  kong.client.get_consumer()
  if not consumer then
    return kong.response.exit(401, { message = "No credentials found" })
  end

  if not conf.consumer_method then
    return kong.response.exit(401, { message = "No consumer configured" })
  end
  
  local auth_consumer = false
  
  for _,v in ipairs(conf.consumer_method) do
    if string.match(consumer.custom_id, v:match("^(%w*):")) then
      auth_consumer = true
      current_consumer_method = v
    break
    end
  end

  if not auth_consumer then
    return kong.response.exit(401, { message = "No consumer authorization found" })
  end

  local nested = ""
  local auth_soap = false
  
  callbacks = {
      StartElement = function (parser, elementName, attributes)
        if elementName == soap_1_1 .. "?Envelope" or elementName == soap_1_2 .. "?Envelope" then
          nested = elementName
        elseif (elementName == soap_1_1 .. "?Body" and nested == soap_1_1 .. "?Envelope") or
               (elementName == soap_1_2 .. "?Body" and nested == soap_1_2 .. "?Envelope") then
          nested = "Envelope/Body"
        elseif (nested == "Envelope/Body") then
            for method in current_consumer_method:match("%:(.*)"):gmatch("%w+") do
              if elementName == method then
                auth_soap= true
                break
              end
            end
          return
        end
      end
  }

  local p = lxp.new(callbacks, "?")
  local result = p:parse(xml)
  if not(auth_soap) then
    return kong.response.exit(401, { message = "Unauthorized" })
  end

end


SoapMethodAuth.PRIORITY = 1000
SoapMethodAuth.VERSION = "1.0.0"


return SoapMethodAuth

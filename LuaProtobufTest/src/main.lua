
cc.FileUtils:getInstance():setPopupNotify(false)

require "config"
require "cocos.init"

local label = nil
local function main()
    --require("app.MyApp"):create():run()

    local pbFilePath = cc.FileUtils:getInstance():fullPathForFilename("MsgProtocol.pb")
    release_print("PB file path: "..pbFilePath)
    
    local buffer = read_protobuf_file_c(pbFilePath)
    protobuf.register(buffer) --注:protobuf 是因为在protobuf.lua里面使用module(protobuf)来修改全局名字
    
    local stringbuffer = protobuf.encode("Person",      
        {      
            name = "Alice",      
            id = 12345,      
            phone = {      
                {      
                    number = "87654321"      
                },      
            }      
        })           
    
    
    local slen = string.len(stringbuffer)
    release_print("slen = "..slen)
    
    local temp = ""
    for i=1, slen do
        temp = temp .. string.format("0xX, ", string.byte(stringbuffer, i))
    end
    release_print(temp)
    local result = protobuf.decode("Person", stringbuffer)
    release_print("result name: "..result.name)
    release_print("result name: "..result.id)


    -- tips
    local sceneGame = cc.Director:getInstance():getRunningScene()
    if sceneGame == nil then
    	sceneGame = cc.Scene:create()
        cc.Director:getInstance():runWithScene(sceneGame)
    end

    local layer = cc.Layer:create()
    sceneGame:addChild(layer)
    label = ccui.Text:create(result.name.." - "..result.id, "Arial", 30)
    label:setPosition(cc.p(layer:getContentSize().width*0.5, layer:getContentSize().height*0.5))
    layer:addChild(label)
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
    --label:setText(msg)
end

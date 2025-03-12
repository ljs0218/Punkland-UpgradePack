string.empty = ""

local Constants = {
    SAYTYPE = {
        NEARBY = 0,
        ALL = 1,
        WHISPER = 2,
        WHISPER_TO = 3,
        CLAN = 4,
        SYSTEM = 5,
        PARTY = 6
    }
}

-- 채팅 관련 설정 초기화 함수
local function initializeChatTypes()
    local chatTypes = {
        {name = "ALL"},
        {type = Constants.SAYTYPE.ALL, name = "전체", color = Color.white},
        {type = Constants.SAYTYPE.NEARBY, name = "근처", color = Color(195, 223, 255)},
        {type = Constants.SAYTYPE.WHISPER_TO, name = "귓속말", color = Color(255, 167, 41)},
        {type = Constants.SAYTYPE.CLAN, name = "클랜", color = Color(1, 255, 234)},
        {type = Constants.SAYTYPE.PARTY, name = "파티", color = Color(255, 255, 0)},
        {type = Constants.SAYTYPE.SYSTEM, name = "시스템", color = Color(0, 255, 0)}
    }
    return chatTypes
end

local chat_fontsize = 14 -- 채팅 시스템 폰트사이즈 설정
local maxchat = 70 -- 최대 채팅 갯수 설정
StartChat.visible = false -- 초기 채팅 입력창 끄기

local CustomChat = {
    ChatMessages = {},
    ChatCellHeight = 20,
    CurrentIndex = 1,
    ChatType = initializeChatTypes(),
    IndexById = {}
}

-- 채팅 유형별 인덱스를 맵핑합니다.
local function mapChatTypeIndexes(chatTypes)
    local indexMap = {}
    for i, entry in ipairs(chatTypes) do
        if entry.type then
            indexMap[entry.type] = i
        end
    end
    return indexMap
end

CustomChat.IndexById = mapChatTypeIndexes(CustomChat.ChatType)

function CustomChat.HandleRedDot(index, visible)
    local targetDot = CustomChat.dots[index]
    targetDot.visible = visible
    if not targetDot.visible then
        targetDot.scaleX, targetDot.scaleY = 0, 0
        targetDot.DOScale(Point(1, 1), 0.3)
    end
end

function CustomChat.CreateChatPanel()
    ChatUI.visible = false

    local mainPanel =
        Image("Pictures/panel_beige.png") {
        rect = Rect(0, 50, 400, 250),
        opacity = 0,
        imageType = 1
    }

    local horizontal = HorizontalPanel(Rect(0, 0, mainPanel.width, 20))
    horizontal.visible = false
    horizontal.SetParent(mainPanel)

    local tab = {}
    local redDot = {}
    for i = 1, #CustomChat.ChatType do
        tab[i] =
            Button() {
            text = nil,
            rect = Rect(0, 0, mainPanel.width / #CustomChat.ChatType, horizontal.height),
            opacity = 0,
            textAlign = 4,
            imageType = 1,
            masked = false
        }
        --tab[i].SetImage("Pictures/panel_deepPurple.png")
        tab[i].SetParent(horizontal)
        tab[i].onClick.Add(
            function()
                CustomChat.CurrentIndex = i
                CustomChat.RefreshCell(i)
            end
        )

        local chatTypeText =
            Text() {
            rect = Rect(0, 0, tab[i].width, tab[i].height),
            text = CustomChat.ChatType[i].name,
            textSize = chat_fontsize,
            textAlign = 4,
            anchor = 4,
            pivot = Point(0.5, 0.5)
        }

        chatTypeText.borderDistance = Point(1, 1)
        chatTypeText.borderEnabled = true

        chatTypeText.SetParent(tab[i])

        redDot[i] =
            Image("Pictures/HUD/icon_dia.png") {
            rect = Rect(0, -3, 8, 8),
            pivot = Point(0.5, 1),
            anchor = 1,
            visible = false,
            color = Color.red
        }
        redDot[i].SetParent(chatTypeText)
    end

    local chatScroll =
        ScrollPanel() {
        rect = Rect(5, 25, mainPanel.width - 10, mainPanel.height - 80),
        horizontal = false,
        color = Color.black,
        opacity = 5
    }
    chatScroll.SetParent(mainPanel)

    local vertical = VerticalPanel(Rect(0, 0, chatScroll.width, chatScroll.height))
    chatScroll.content = vertical

    CustomChat.mainPanel = mainPanel
    CustomChat.chatScroll = chatScroll
    CustomChat.chatTable = vertical
    CustomChat.tabs = tab
    CustomChat.dots = redDot

    local chat_plus =
        Button() {
        text = "",
        rect = Rect(5, mainPanel.height + 42, 32, 32),
        opacity = 0,
        textAlign = 4,
        imageType = 1,
        masked = false
    }
    local chat_plusicon = Image("Pictures/HUD/ui_icons/icon_chating.png", Rect(0, 0, chat_plus.width, chat_plus.height))
    chat_plusicon.SetOpacity(90)
    chat_plusicon.SetParent(chat_plus)
    --chat_plus.SetParent(mainPanel)
    CustomChat.clickCount = 0 -- 클릭 카운터 초기화

    chat_plus.onClick.Add(
        function()
            CustomChat.clickCount = CustomChat.clickCount + 1 -- 클릭 카운터를 증가

            if CustomChat.clickCount == 1 then
                -- 첫 번째 클릭
                StartChat.visible = true
                horizontal.visible = true -- horizontal 패널 토글
                if not mainPanel.visible then
                    mainPanel.ToggleVisible()
                end
                chatScroll.SetOpacity(100) -- chatScroll 투명도 100 설정
                chatScroll.height = chatScroll.height + 50 -- chatScroll 높이 증가
            elseif CustomChat.clickCount == 2 then
                -- 두 번째 클릭
                mainPanel.ToggleVisible()
                StartChat.visible = false
            elseif CustomChat.clickCount == 3 then
                -- 세 번째 클릭

                mainPanel.visible = true
                horizontal.visible = false -- horizontal 패널 토글
                chatScroll.height = chatScroll.height - 50 -- chatScroll 높이 감소
                chatScroll.SetOpacity(5) -- chatScroll 투명도 5 설정
                CustomChat.clickCount = 0
            end

            CustomChat.RefreshCell(CustomChat.CurrentIndex) -- 채팅 셀 갱신
        end
    )
    CustomChat.chat_plus = chat_plus
end

function CustomChat.ColorByType(index)
    return CustomChat.ChatType[index].color
end

function CustomChat.AddChat(chat, isString)
    if isString then
        chat = Utility.JSONParse(chat)
    end
    local indexByID = CustomChat.IndexById[chat.type]
    CustomChat.InsertMessage(indexByID, chat)

    if CustomChat.CurrentIndex == 1 or CustomChat.CurrentIndex == indexByID then
        CustomChat.RefreshCell(CustomChat.CurrentIndex)
    end
    if CustomChat.CurrentIndex == 1 or CustomChat.CurrentIndex ~= indexByID then
        CustomChat.HandleRedDot(indexByID, true)
    end
end

function CustomChat.InsertMessage(index, chat)
    -- 메시지가 해당 인덱스의 배열에 추가되기 전에 배열 초기화 확인
    if not CustomChat.ChatMessages[index] then
        CustomChat.ChatMessages[index] = {}
    end

    -- 메시지 배열에 새 메시지 추가
    table.insert(
        CustomChat.ChatMessages[index],
        {name = chat.name, text = chat.text, color = CustomChat.ColorByType(index)}
    )

    -- 메시지가 최대 수를 초과하면 가장 오래된 메시지를 배열에서 제거
    if #CustomChat.ChatMessages[index] > maxchat then
        table.remove(CustomChat.ChatMessages[index], 1)
    end

    -- '전체' 채팅에도 동일하게 메시지 추가 및 관리
    if index ~= Constants.SAYTYPE.ALL then -- '전체' 탭은 모든 메시지를 보여주므로 별도 관리
        if not CustomChat.ChatMessages[Constants.SAYTYPE.ALL] then
            CustomChat.ChatMessages[Constants.SAYTYPE.ALL] = {}
        end
        table.insert(
            CustomChat.ChatMessages[Constants.SAYTYPE.ALL],
            {name = chat.name, text = chat.text, color = CustomChat.ColorByType(index)}
        )

        -- '전체' 탭의 메시지도 최대 수를 초과하면 가장 오래된 메시지를 배열에서 제거
        if #CustomChat.ChatMessages[Constants.SAYTYPE.ALL] > maxchat then
            table.remove(CustomChat.ChatMessages[Constants.SAYTYPE.ALL], 1)
        end
    end
end

-- 선택된 탭의 투명도를 설정합니다.
local function setTabOpacity(tab, isActive)
    tab.children[1].opacity = isActive and 255 or 120
end
local chatCellPool = {}

-- 채팅 테이블의 모든 메시지 셀을 재사용 풀로 이동합니다.
local function clearChatCells(chatTable)
    for i = #chatTable.children, 1, -1 do
        local child = table.remove(chatTable.children, i)
        child.visible = false -- 셀을 숨깁니다.
        table.insert(chatCellPool, child) -- 셀을 풀에 추가합니다.
    end
end

-- 채팅 메시지 셀을 생성하거나 재사용합니다.
local function createChatCell(chatData, chatTable, chatCellHeight, fontSize)
    local chatCell
    if #chatCellPool > 0 then
        -- 셀 속성을 새 메시지 데이터로 업데이트합니다.
        chatCell = table.remove(chatCellPool) -- 풀에서 셀을 가져옵니다.
    else
        -- 풀이 비어있으면 새 셀을 생성합니다.
        chatCell =
            Text() {
            rect = Rect(0, 0, chatTable.width, chatCellHeight),
            anchor = 4,
            textSize = fontSize,
            lineSpacing = 0.9,
            borderDistance = Point(1, 1),
            borderEnabled = true
        }
    end
    -- 새 데이터 설정
    chatCell.text = chatData.name == string.empty and chatData.text or chatData.name .. " : " .. chatData.text
    chatCell.color = chatData.color
    chatCell.visible = true -- 셀을 보이게 합니다.
    chatCell.SetParent(chatTable) -- 셀을 채팅 테이블에 추가합니다.
end
-- 특정 인덱스의 채팅 탭을 새로고침합니다.
function CustomChat.RefreshCell(index)
    if CustomChat.clickCount == 2 then
        return
    end

    -- 빨간 점 표시 처리
    if CustomChat.dots[index].visible then
        CustomChat.HandleRedDot(index, false)
    end

    -- 선택된 인덱스에 따라 탭의 투명도 조정
    for i, tab in pairs(CustomChat.tabs) do
        setTabOpacity(tab, i == index)
    end

    local messages = CustomChat.ChatMessages[index] or {}
    local numCells = #CustomChat.chatTable.children
    local numMessages = #messages

    -- 채팅 메시지 업데이트 또는 새 셀 생성
    for i = 1, numMessages do
        local chatData = messages[i]
        local chatCell = CustomChat.chatTable.children[i]

        if not chatCell then
            chatCell = createChatCell(chatData, CustomChat.chatTable, CustomChat.ChatCellHeight, chat_fontsize)
        else
            chatCell.text = chatData.name == string.empty and chatData.text or chatData.name .. " : " .. chatData.text
            chatCell.color = chatData.color
            chatCell.visible = true
        end
    end

    -- 사용하지 않는 셀 숨기기
    for i = numMessages + 1, numCells do
        CustomChat.chatTable.children[i].visible = false
    end

    -- 채팅 테이블의 높이와 수직 위치 조정
    CustomChat.chatTable.height = #CustomChat.ChatMessages[index] * CustomChat.ChatCellHeight
    local gap = CustomChat.chatTable.height - CustomChat.chatScroll.height
    CustomChat.chatTable.y = gap > 0 and -gap or 0
end

Client.GetTopic("AddChat").Add(
    function(chat, isString)
        CustomChat.AddChat(chat, isString)
    end
)

Client.customData.chat = 0

function CustomChat.Initialize()
    CustomChat.CreateChatPanel()
    --  CustomChat.RefreshCell(CustomChat.CurrentIndex)
    CustomChat.AddChat(
        {
            type = 5,
            name = string.empty,
            text = "<color=yellow>[#] 현재 APP 버전: v" .. Client.appVersion .. "</color>"
        }
    )
    CustomChat.AddChat(
        {
            type = 5,
            name = string.empty,
            text = "<color=yellow>[#] 현재 [" .. Client.platform .. "] 환경에서 접속 중 입니다.</color>"
        }
    )
end

CustomChat.Initialize()

LClient.Events.onShowUI.Add(function ()
    CustomChat.mainPanel.visible = true
    CustomChat.chat_plus.visible = true
end)

LClient.Events.onHideUI.Add(function ()
    CustomChat.mainPanel.visible = false
    CustomChat.chat_plus.visible = false
end)

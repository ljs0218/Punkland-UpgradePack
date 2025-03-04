local Config = {
    -- 클라이언트 설정
    Client = {
        resolution = Point(960, 576), -- 클라이언트의 해상도입니다.
        orthographicSize = 240,       -- 카메라의 직교 크기입니다.
    },

    -- 플레이어 설정
    Player = {
        canJump = true,   -- 캐릭터가 점프할 수 있는지 여부입니다.
        offsetY = 5,      -- 카메라의 Y축 오프셋입니다.
        movementType = 1, -- 카메라의 움직임 타입입니다. 0: 기본 이동 (캐릭터 위치로 정확히 고정됨) 1: 부드러운 카메라 이동
    },

    -- UI 설정
    UI = {
        CustomEquip = {
            title = "커스텀 장비", -- 커스텀 장비 팝업의 제목입니다.
            size = Point(280, 256), -- 커스텀 장비 팝업의 크기입니다.
            -- 타입별 장비 슬롯의 위치입니다.
            slotPosition = {
                [1] = Point(0, -26),
                [2] = Point(0, 26),
            },
        },

        Shop = {
            categorySize = Point(126, 42), -- 상점 카테고리 버튼의 크기입니다.
            productScrollPadding = 20,     -- 상품 스크롤의 패딩입니다.
            productSpacing = 10,           -- 상품 간의 간격입니다.
        },

        HUD = {
            -- 화면에 보일 재화 ID 리스트입니다.
            Currency = {
                ids = { 1, 2, 3 },
            }
        }
    },
}

return Config

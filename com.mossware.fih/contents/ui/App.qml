import QtQuick 6.5
import QtQuick.Window 6.5

Item {
    id: root
    width: 320
    height: 180
    visible: true

    function rand(min, max) {
        return min + Math.random() * (max - min)
    }

    readonly property int pad: 8

    property int themeIndex: 0

    readonly property var themes: [
        {
            bg: "#101518",
            border: "#40252b30",
            prompt: "#8aa0a6",
            seaweed: "#1f5c3a",
            bubbles: "#a0d8ef",
            squiggle: "#7fb7ff",
            fish1: "#a3e6a1",
            fish2: "#8fd3c8",
            fish3: "#7fb7ff"
        },
        {
            bg: "#0b0f0c",
            border: "#203322",
            prompt: "#5cff7a",
            seaweed: "#3cff88",
            bubbles: "#5cff7a",
            squiggle: "#5cff7a",
            fish1: "#5cff7a",
            fish2: "#4bdc6a",
            fish3: "#6aff9a"
        },
        {
            bg: "#120e1a",
            border: "#3a2f55",
            prompt: "#b6a6d8",
            seaweed: "#6b5f9e",
            bubbles: "#8fa3d8",
            squiggle: "#9c7cff",
            fish1: "#a58fd3",
            fish2: "#7fa1c8",
            fish3: "#c38fff"
        },
        {
            bg: "#f4f6f7",
            border: "#b8c0c6",
            prompt: "#1f2d35",
            seaweed: "#163f30",
            bubbles: "#1f4f75",
            squiggle: "#162a7a",
            fish1: "#0b3d0b",
            fish2: "#00332e",
            fish3: "#0d1b5e"
        }
    ]

    readonly property var theme: themes[themeIndex]

    function nextTheme() {
        themeIndex = (themeIndex + 1) % themes.length
    }

    Rectangle {
        id: tank
        anchors.fill: parent
        radius: 2
        clip: true

        color: theme.bg
        border.width: 1
        border.color: theme.border

        Text {
            text: "theme"
            font.family: "monospace"
            font.pixelSize: 11
            color: theme.prompt
            opacity: 0.35

            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: root.pad
            anchors.rightMargin: root.pad

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.nextTheme()
            }
        }

        Text {
            text: "fih:~$"
            font.family: "monospace"
            font.pixelSize: 12
            color: theme.prompt
            opacity: 0.35

            x: root.pad
            y: root.pad
        }

        Repeater {
            model: Math.floor((root.width - 2 * root.pad) / 4)

            Text {
                text: {
                    const forms = ["|", "¦", "!", ":"]
                    forms[Math.floor(Math.random() * forms.length)]
                }
                font.family: "monospace"
                font.pixelSize: rand(8, 14)
                color: theme.seaweed
                opacity: 0.65

                x: root.pad + index * 4
                y: root.height - root.pad - font.pixelSize - 2 - rand(0, 10)
            }
        }

        ListModel { id: floatBubbleModel }

        Timer {
            interval: rand(900, 1500)
            running: true
            repeat: true

            onTriggered: {
                const makeBubble = function(xMin, xMax) {
                    floatBubbleModel.append({
                        x: rand(xMin, xMax),
                                            size: rand(6, 12),
                                            glyph: Math.random() < 0.5 ? "o" : "°",
                                            duration: rand(4500, 9000)
                    })
                }

                const mid = root.width / 2
                makeBubble(root.pad, mid - 6)
                if (Math.random() < 0.85)
                    makeBubble(mid + 6, root.width - root.pad)
            }
        }

        Repeater {
            model: floatBubbleModel

            Text {
                id: fb
                text: model.glyph
                font.family: "monospace"
                font.pixelSize: model.size
                color: theme.bubbles
                opacity: 0.6

                x: model.x
                y: root.height + 10

                ParallelAnimation {
                    running: true

                    NumberAnimation {
                        target: fb
                        property: "y"
                        from: root.height + 10
                        to: -30
                        duration: model.duration
                        easing.type: Easing.InOutSine
                    }

                    NumberAnimation {
                        target: fb
                        property: "opacity"
                        from: 0.6
                        to: 0
                        duration: model.duration
                    }

                    onFinished: floatBubbleModel.remove(index)
                }
            }
        }

        Repeater {
            model: 22

            Text {
                text: Math.random() < 0.5 ? "·" : "o"
                font.family: "monospace"
                font.pixelSize: rand(6, 10)
                color: theme.bubbles
                opacity: 0

                x: rand(root.pad, root.width - root.pad)
                y: rand(root.pad + 12, root.height - root.pad - 40)

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { from: 0; to: 0.5; duration: rand(1500, 3500) }
                    NumberAnimation { from: 0.5; to: 0; duration: rand(1500, 3500) }
                }
            }
        }

        Repeater {
            model: 4

            Text {
                text: Math.random() < 0.5 ? "~" : "~~"
                font.family: "monospace"
                font.pixelSize: rand(10, 16)
                color: theme.squiggle
                opacity: 0

                x: rand(root.pad, root.width - root.pad - 50)
                y: rand(root.pad + 20, root.height - root.pad - 70)

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { from: 0; to: 0.28; duration: rand(2500, 5000) }
                    NumberAnimation { from: 0.28; to: 0; duration: rand(2500, 5000) }
                }
            }
        }

        readonly property int minFish: 4
        readonly property int preferredFish: 5
        readonly property int softMaxFish: 7
        readonly property int hardMaxFish: 10

        ListModel { id: fishModel }

        Component.onCompleted: {
            let initial = Math.floor(rand(4, 6))
            for (let i = 0; i < initial; i++)
                tank.spawnFish()
        }

        function spawnFish() {
            if (fishModel.count >= tank.hardMaxFish) return

                let type = Math.floor(rand(0, 3))

                if (type === 0) {
                    fishModel.append({
                        glyphRight: "<>",
                        glyphLeft: "<>",
                        size: 10,
                        speed: rand(6000, 9000),
                                     turnChance: 0.85,
                                     y: rand(root.pad + 12, root.height / 2),
                                     color: theme.fish1
                    })
                } else if (type === 1) {
                    fishModel.append({
                        glyphRight: "><>",
                        glyphLeft: "<><",
                        size: 14,
                        speed: rand(10000, 14000),
                                     turnChance: 0.75,
                                     y: rand(root.pad + 18, root.height - root.pad - 45),
                                     color: theme.fish2
                    })
                } else {
                    let yPos = (Math.random() < 0.7)
                    ? rand(root.height / 2, root.height - root.pad - 30)
                    : rand(root.pad + 20, root.height - root.pad - 30)

                    fishModel.append({
                        glyphRight: "><((º>",
                                     glyphLeft: "<º))><",
                                     size: 18,
                                     speed: rand(16000, 22000),
                                     turnChance: 0.8,
                                     y: yPos,
                                     color: theme.fish3
                    })
                }
        }

        function removeFish() {
            if (fishModel.count <= tank.minFish) return
                fishModel.remove(Math.floor(rand(0, fishModel.count)))
        }

        Timer {
            interval: 15000
            running: true
            repeat: true

            onTriggered: {
                let n = fishModel.count
                if (n < tank.preferredFish) tank.spawnFish()
                    else if (n <= tank.softMaxFish)
                        Math.random() < 0.55 ? tank.spawnFish() : tank.removeFish()
                        else if (n < tank.hardMaxFish)
                            Math.random() < 0.25 ? tank.spawnFish() : tank.removeFish()
                            else tank.removeFish()
            }
        }

        Repeater {
            model: fishModel

            Fish {
                glyphRight: model.glyphRight
                glyphLeft: model.glyphLeft
                font.pixelSize: model.size
                color: model.color
                baseY: model.y
                speed: model.speed
                turnChance: model.turnChance
            }
        }
    }
}

// Monstertov - https://tov.monster/
// monstertov glass: sddm login theme (qt6)
import QtQuick
import QtQuick.Effects
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#141414"

    readonly property color light: "#65b9f0"
    readonly property color deep: "#0071bc"
    readonly property color muted: "#b4b4b4"
    property int sessionIndex: sessionModel.lastIndex
    // lastUser is empty until the first login, so fall back to the first user on the system
    // (257 is Qt.UserRole + 1, the user model's name role)
    property string userName: userModel.lastUser !== ""
        ? userModel.lastUser
        : userModel.data(userModel.index(0, 0), 257)

    Connections {
        target: sddm
        function onLoginFailed() {
            password.text = ""
            message.text = "wrong password"
            password.forceActiveFocus()
        }
    }

    Image {
        id: wallpaper
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
    }

    Text {
        id: clock
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: card.top
        anchors.bottomMargin: 40
        color: "white"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 96
        font.bold: true
        text: Qt.formatTime(new Date(), "HH:mm")
        Timer {
            interval: 1000; running: true; repeat: true
            onTriggered: clock.text = Qt.formatTime(new Date(), "HH:mm")
        }
    }

    // the glass: a blurred copy of the wallpaper clipped to the card
    Item {
        id: card
        width: 400
        height: 260
        anchors.centerIn: parent

        Item {
            id: glassSource
            anchors.fill: parent
            clip: true
            visible: false
            layer.enabled: true
            Image {
                x: -card.x; y: -card.y
                width: root.width; height: root.height
                source: config.background
                fillMode: Image.PreserveAspectCrop
            }
        }

        Rectangle {
            id: mask
            anchors.fill: parent
            radius: 18
            visible: false
            layer.enabled: true
        }

        MultiEffect {
            anchors.fill: parent
            source: glassSource
            blurEnabled: true
            blur: 1.0
            blurMax: 64
            brightness: -0.25
            maskEnabled: true
            maskSource: mask
        }

        Rectangle {
            anchors.fill: parent
            radius: 18
            color: Qt.rgba(0.08, 0.08, 0.08, 0.35)
            border.width: 2
            border.color: Qt.rgba(0, 0.443, 0.737, 0.75)
        }

        Column {
            anchors.centerIn: parent
            spacing: 14
            width: parent.width - 60

            Text {
                text: sddm.hostName
                color: root.light
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 22
                font.bold: true
                font.letterSpacing: 2
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                width: parent.width
                height: 48
                radius: 12
                color: Qt.rgba(1, 1, 1, 0.06)
                border.width: 1
                border.color: password.activeFocus ? root.light : Qt.rgba(1, 1, 1, 0.12)

                TextInput {
                    id: password
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    color: "white"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 16
                    focus: true
                    onAccepted: sddm.login(root.userName, password.text, root.sessionIndex)

                    Text {
                        visible: password.text.length === 0
                        anchors.verticalCenter: parent.verticalCenter
                        text: "password"
                        color: root.muted
                        font: password.font
                    }
                }
            }

            Text {
                id: message
                text: ""
                color: "#e06c75"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 24
        spacing: 24

        Text {
            text: "⏻"
            color: root.muted
            font.pixelSize: 22
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: sddm.powerOff() }
        }
        Text {
            text: "↻"
            color: root.muted
            font.pixelSize: 22
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: sddm.reboot() }
        }
    }

    Component.onCompleted: password.forceActiveFocus()
}

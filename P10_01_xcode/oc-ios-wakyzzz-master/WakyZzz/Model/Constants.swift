//
//  Constants.swift
//  WakyZzz
//
//  Created by Ahmad Murad on 24/03/2020.
//  Copyright © 2020 Olga Volkova OC. All rights reserved.
//

import Foundation

enum ActionButtonsID: String {
    case
        First_Snooze,
        Second_Snooze,
        Text_Friend,
        Text_Family,
        Do_It_Later,
        Delete_Alarm,
        Task_complete,
        Defer
}

enum ActionButtonsTitle: String {
    case
        Snooze,
        Delete,
        SnoozeAgain = "Snooze Again",
        messageFriend = "message a friend",
        messageFamily = "message a family member",
        deferTask = "I promis I will do it later",
        taskComplete = "I have completed the task",
        deferTaskAgain = "No, seriously I promis I will do it later"
}

enum AlarmSoundNames: String {
    case
        firstAlarmSound = "firstSound.mp3",
        secondAlarmSound = "secondSound.mp3",
        scaryAlarmSound = "scarySound.mp3"
}

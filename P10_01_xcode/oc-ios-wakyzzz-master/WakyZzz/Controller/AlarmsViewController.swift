//
//  AlarmsViewController.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class AlarmsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AlarmCellDelegate, SettingAlarmViewControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var alarms = [Alarm]()
    var editingIndexPath: IndexPath?
    // date formatter to string alarm.alarmDate to be used as an Identifier
    let formatter = DateFormatter()
    
    
    
    @IBAction func addButtonPress(_ sender: Any) {
        presentAlarmViewController(alarm: nil)
    }

    // MARK: - Configuration
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        config()
    }
    
    func config() {
        
        tableView.delegate = self
        tableView.dataSource = self
        CoreDataManager.shared.refresh()
        loadAlarmsFromCoreDataAndPopulateTableView()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    func populateAlarms() {
        
        let firstInitialAlarm = Alarms(entity: Alarms.entity(), insertInto: CoreDataManager.shared.context)
        // Weekdays 5am
        firstInitialAlarm.time = 5 * 3600
        firstInitialAlarm.repeatMon = true
        firstInitialAlarm.repeatTue = true
        firstInitialAlarm.repeatWed = true
        firstInitialAlarm.repeatThu = true
        firstInitialAlarm.repeatFri = true
        firstInitialAlarm.repeatSat = false
        firstInitialAlarm.repeatSun = false
        firstInitialAlarm.enabled   = true
        // CreationDate is used as an alarm identifier
        firstInitialAlarm.creationDateID = stringFrom(Date())
        CoreDataManager.shared.appDelegate.saveContext()
        
        let secondInitialAlarm = Alarms(entity: Alarms.entity(), insertInto: CoreDataManager.shared.context)
        // Weekend 9am
        secondInitialAlarm.time = 9 * 3600
        secondInitialAlarm.enabled = false
        secondInitialAlarm.repeatMon = false
        secondInitialAlarm.repeatTue = false
        secondInitialAlarm.repeatWed = false
        secondInitialAlarm.repeatThu = false
        secondInitialAlarm.repeatFri = false
        secondInitialAlarm.repeatSun = true
        secondInitialAlarm.repeatSat = true
        // CreationDate is used as an alarm identifier
        secondInitialAlarm.creationDateID = stringFrom(Date())
        CoreDataManager.shared.appDelegate.saveContext()
        CoreDataManager.shared.refresh()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath) as! AlarmTableViewCell
        cell.delegate = self
        if let alarm = alarm(at: indexPath) {
            cell.populate(caption: alarm.caption, subcaption: alarm.repeating, enabled: alarm.enabled)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.deleteAlarm(at: indexPath)
        }
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            self.editAlarm(at: indexPath)
        }
        return [delete, edit]
    }
    
    func alarm(at indexPath: IndexPath) -> Alarm? {
        // FIXME: - fetch alarm from Alarms coredata database instead
        return indexPath.row < alarms.count ? alarms[indexPath.row] : nil
    }
    
    func deleteAlarm(at indexPath: IndexPath) {
        removePendingNotificationFor(alarmID: (alarm(at: indexPath)?.alarmDate)!)
        
        if let alarm = CoreDataManager.shared.fetchedRC?.object(at: indexPath) {
            //            manageLocalNotification(alarm.enabled?, alarm.time, alarm.repeatedDays, alarm.creationDateID)
            // or removePedingNotificationWith(indentifier: identifier)
            CoreDataManager.shared.context.delete(alarm)
            CoreDataManager.shared.appDelegate.saveContext()
        }
        tableView.beginUpdates()
        alarms.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func editAlarm(at indexPath: IndexPath) {
        editingIndexPath = indexPath
        presentAlarmViewController(alarm: alarm(at: indexPath))
    }
    
    func addOrEdit(_ alarm: Alarm, at indexPath: IndexPath? = nil) {
        
        if indexPath != nil {
            if let alarmToEdit = CoreDataManager.shared.fetchedRC?.object(at: indexPath!) {
                alarmToEdit.time = Int32(alarm.time)
                alarmToEdit.repeatSun = alarm.repeatDays[0]
                alarmToEdit.repeatMon = alarm.repeatDays[1]
                alarmToEdit.repeatTue = alarm.repeatDays[2]
                alarmToEdit.repeatWed = alarm.repeatDays[3]
                alarmToEdit.repeatThu = alarm.repeatDays[4]
                alarmToEdit.repeatFri = alarm.repeatDays[5]
                alarmToEdit.repeatSat = alarm.repeatDays[6]
                alarmToEdit.enabled   = alarm.enabled
                //            manageLocalNotification(alarm.enabled?, alarm.time, alarm.repeatedDays, alarm.creationDateID)
                
                // CreationDate is used as an alarm identifier
//                alarmToEdit.creationDateID = Date()
                CoreDataManager.shared.appDelegate.saveContext()
            }
        } else {
            let newAlarm = Alarms(entity: Alarms.entity(), insertInto: CoreDataManager.shared.context)
            newAlarm.time = Int32(alarm.time)
            newAlarm.repeatSun = alarm.repeatDays[0]
            newAlarm.repeatMon = alarm.repeatDays[1]
            newAlarm.repeatTue = alarm.repeatDays[2]
            newAlarm.repeatWed = alarm.repeatDays[3]
            newAlarm.repeatThu = alarm.repeatDays[4]
            newAlarm.repeatFri = alarm.repeatDays[5]
            newAlarm.repeatSat = alarm.repeatDays[6]
            newAlarm.enabled   = alarm.enabled
            // CreationDate is used as an alarm identifier
            newAlarm.creationDateID = stringFrom(alarm.alarmDate!)
            //            manageLocalNotification(alarm.enabled?, alarm.time, alarm.repeatedDays, alarm.creationDateID)
            CoreDataManager.shared.appDelegate.saveContext()
        }
//        tableView.beginUpdates()
//        alarms.insert(alarm, at: indexPath.row)
//        tableView.insertRows(at: [indexPath], with: .automatic)
//        tableView.endUpdates()
    }
    
    func moveAlarm(from originalIndextPath: IndexPath, to targetIndexPath: IndexPath) {
        let alarm = alarms.remove(at: originalIndextPath.row)
        alarms.insert(alarm, at: targetIndexPath.row)
        tableView.reloadData()
    }
    
    func alarmCell(_ cell: AlarmTableViewCell, enabledChanged enabled: Bool) {
        if let indexPath = tableView.indexPath(for: cell) {
            if let alarm = self.alarm(at: indexPath) {
                alarm.enabled = enabled
                alarm.enabled ? manageSettingUpLocalNotificationFor(alarm) : removePendingNotificationFor(alarmID: alarm.alarmDate!)
                addOrEdit(alarm, at: indexPath)
            }
        }
    }
    
    func presentAlarmViewController(alarm: Alarm?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let popupViewController = storyboard.instantiateViewController(withIdentifier: "DetailNavigationController") as! UINavigationController
        let settingAlarmViewController = popupViewController.viewControllers[0] as! SettingAlarmViewController
        settingAlarmViewController.alarm = alarm
        settingAlarmViewController.delegate = self
        present(popupViewController, animated: true, completion: nil)
    }
    
    func alarmViewControllerDone(alarm: Alarm) {
        // if it was editing existing alarm
        if let editingIndexPath = editingIndexPath {
            addOrEdit(alarm, at: editingIndexPath)
            loadAlarmsFromCoreDataAndPopulateTableView()
        }
        // if it was adding new alarm
        else {
            manageSettingUpLocalNotificationFor(alarm)
            addOrEdit(alarm)
            loadAlarmsFromCoreDataAndPopulateTableView()
        }
        editingIndexPath = nil
    }
    
    func alarmViewControllerCancel() {
        editingIndexPath = nil
    }
    
    func loadAlarmsFromCoreDataAndPopulateTableView() {
        alarms.removeAll()
        CoreDataManager.shared.refresh()
        
        // If app opens for the first time populate with two standard alarms
        if CoreDataManager.shared.fetchedRC.fetchedObjects == [] {
            populateAlarms()
        }
        
        guard let savedAlarms = CoreDataManager.shared.fetchedRC.fetchedObjects else {return}
        
        for i in savedAlarms {
            let alarm = Alarm()
            alarm.time = Int(i.time)
            alarm.enabled = i.enabled
            alarm.repeatDays = [i.repeatSun, i.repeatMon, i.repeatTue, i.repeatWed, i.repeatThu, i.repeatFri, i.repeatSat]
            alarms.append(alarm)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}

// MARK: - Notifications
extension AlarmsViewController: UNUserNotificationCenterDelegate {
    
    func stringFrom(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMddyyyyhhmmss"
        return formatter.string(from: date)
    }
    
    func manageSettingUpLocalNotificationFor(_ alarm: Alarm) {
        
        let date = alarm.alarmDate
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date!)
        let minute = calendar.component(.minute, from: date!)
        
        var weekDay = 1
        
        if alarm.repeating == "One time alarm" {
            schedualeLocalNotification(time: alarm.caption, hour: hour, minute: minute, weekDay: weekDay, body: alarm.caption, contentIdentifier: stringFrom(alarm.alarmDate!))
        } else {
            for weekDays in alarm.repeatDays {
                if weekDays == true {
                    schedualeLocalNotification(time: alarm.caption, hour: hour, minute: minute, weekDay: weekDay, body: alarm.caption, contentIdentifier: stringFrom(alarm.alarmDate!) + "\(weekDay)")
                }
                weekDay += 1
            }
        }
    
        
        // here you manage setting up notifications once we get the alarm back from settingAlarmViewController
        
        // check if alarm is enabled by a condition statement for edited alarm returning from settingAlarmViewController
        // and for edited alarm remove its previous pending notifications using its creationDateID before setting it up again
        
        // if enabled structure it up and call schedualeLocalNotification
    }
    
    func schedualeLocalNotification(time: String, hour: Int, minute: Int, weekDay: Int, body: String, contentIdentifier: String) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        // remove previously scheduled notification
        let identifier = contentIdentifier
//        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
        
        // Create content
        let content = UNMutableNotificationContent()
        content.title = "WakyZzz"
        content.subtitle = "This is the alarm you set up to wake and act"
        content.body = body
        let categoryIdentifier = time
        content.categoryIdentifier = categoryIdentifier
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "sound.mp3"))
        // create rquest
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.weekday = weekDay
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        // create trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // create request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        // create action buttons
        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        let deleteAction = UNNotificationAction(identifier: "Delete", title: "Delete", options: .destructive)
        let category = UNNotificationCategory(identifier: categoryIdentifier, actions: [snoozeAction, deleteAction], intentIdentifiers: [], options: [])
        
        notificationCenter.setNotificationCategories([category])
        
        
//        // Create trigger
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//
//        // Create request
//        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
//
//        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func removePendingNotificationFor(alarmID: Date) {
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            for request in requests {
                if request.identifier.contains(self.stringFrom(alarmID)) {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
                    // and also remove its delivered notifications
                    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [request.identifier])
                }
            }
        }
    }
    
    // this block of code only runs when app is running in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // update alarm to turn off enabled attribute if it was a one time alarm
        grabStoredObjectAndUpdate(notification.request.identifier)
        // after updating the persisted object we need to loadAlarms to relect changes in UI
        loadAlarmsFromCoreDataAndPopulateTableView()
        // calling completion handler to specify how I want the system to alert the user
        completionHandler([.alert, .sound])
        
        // FIXME: - check if this delivered alarm has been removed
    }
    
    func grabStoredObjectAndUpdate(_ alarmCreationID: String) {
        if let alarm = CoreDataManager.shared.fetchAlarm(with: alarmCreationID) {
            let repeatDays = [alarm.repeatSun, alarm.repeatMon, alarm.repeatTue, alarm.repeatWed, alarm.repeatThu, alarm.repeatFri, alarm.repeatSat]
            if repeatDays.allSatisfy({$0 == false}) {
                alarm.enabled = false
            }
        }
    }
    
    // process the user's response to a delivered notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // The runtime state of the app.
        let state = UIApplication.shared.applicationState
        
        // when the app is running in the background.
        if state == .background {
            // update alarm to turn off enabled attribute if it was a one time alarm
            grabStoredObjectAndUpdate(response.notification.request.identifier)
            // after updating the persisted object we need to loadAlarms to reflect changes in UI
            loadAlarmsFromCoreDataAndPopulateTableView()
            
        // when the app is running in the foreground but is not receiving events. This might happen as a result of an interruption or because the app is transitioning to or from the background.
        } else if state == .inactive {
            // update alarm to turn off enabled attribute if it was a one time alarm
            grabStoredObjectAndUpdate(response.notification.request.identifier)
        }
        
        if response.actionIdentifier == "Snooze" {
            // call snoozeButtonPressed
            
        } else if response.actionIdentifier == "SecondSnooze" {
            // call snoozeButtonPressed
        } else if response.actionIdentifier == "TextFriend" {
            // open sms app and fill it in predetermied message
        } else if response.actionIdentifier == "TextFamily" {
            // open sms app and fill it in with predetermined text
        } else if response.actionIdentifier == "DoItLater" {
            
        } else if response.actionIdentifier == "DeleteAlarm" {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [response.notification.request.identifier])
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [response.notification.request.identifier])
        }
        // calling the completionHandler block to let the system know that we are done processing the user's response. If we do not implement this method, our app never responds to custom actions.
        completionHandler()
    }
    
    // you need two functions to handle pressing snooze button two times and a function to handle Random act of kindness reminders if user promissed to do it later.
    
}


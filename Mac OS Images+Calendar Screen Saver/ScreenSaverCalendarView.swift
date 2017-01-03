/*
 * Mac OS Images+Calendar Screen Saver
 *
 * file: ScreenSaverCalendarView.swift
 * designation: ScreenSaverCalendarView class
 *
 * Copyright (C) 2016 Maxim Avilov (maxim.avilov@gmail.com)
 *
 * This file is part of Mac OS Images+Calendar Screen Saver
 *
 * Mac OS Images+Calendar Screen Saver is free software: you can
 * redistribute it and/or modify it under the terms of the GNU General
 * Public License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * (Этот файл — часть Mac OS Images+Calendar Screen Saver
 * Mac OS Images+Calendar Screen Saver -  свободная программа: вы можете
 * перераспространять ее и/или изменять ее на условиях Стандартной
 * общественной лицензии GNU в том виде, в каком она была опубликована
 * Фондом свободного программного обеспечения; либо версии 3 лицензии,
 * либо (по вашему выбору) любой более поздней версии.
 *
 * Эта программа распространяется в надежде, что она будет полезной,
 * но БЕЗО ВСЯКИХ ГАРАНТИЙ; даже без неявной гарантии ТОВАРНОГО ВИДА
 * или ПРИГОДНОСТИ ДЛЯ ОПРЕДЕЛЕННЫХ ЦЕЛЕЙ. Подробнее см. в Стандартной
 * общественной лицензии GNU.
 *
 * Вы должны были получить копию Стандартной общественной лицензии GNU
 * вместе с этой программой. Если это не так, см.
 * <http://www.gnu.org/licenses/>.)
 *
 * +++++++++++++[>+>+++++>+++++++++>++++++++>++>++++++<<<<<<-]>>.>.-.>.<-----.++
 * +.<-------.>>>++++++.>-.<<-------.<++++++.>++++++++.++++.>.<<<+++++++.>--.>--
 * --.+++.+++.<.<<---.
 */

import Cocoa
import ScreenSaver

let imagesCount = 4

extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

class ScreenSaverCalendarView: ScreenSaverView {
    
    var images: [NSImage] = []
    
    var currentImageIdx = 0
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        for index in 1...imagesCount {
            if let path = Bundle(for: type(of: self)).path(forResource: String(index), ofType:"png") as String? {
                if let image = NSImage(contentsOfFile: path) {
                    images.append(image)
                }
            }
        }
        let elFontUrl = Bundle(for: type(of: self)).url(forResource: "SourceCodePro-ExtraLight", withExtension: "otf")
        let bFontUrl = Bundle(for: type(of: self)).url(forResource: "SourceCodePro-Bold", withExtension: "otf")
        CTFontManagerRegisterFontsForURL(elFontUrl as! CFURL, .process, nil)
        CTFontManagerRegisterFontsForURL(bFontUrl as! CFURL, .process, nil)
        //Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.animateOneFrame), userInfo: nil, repeats: true) //For debug
        self.animationTimeInterval = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: NSRect) {
        if !images.isEmpty {
            images[currentImageIdx].draw(in: NSMakeRect(0, 0, frame.size.width, frame.size.height), from: NSZeroRect, operation: .sourceOver, fraction: 1)
            
            let calendarBox = NSMakeRect(frame.size.width*0.03, frame.size.height*0.01, frame.size.width*0.62, frame.size.height*0.14)
            let vShiftUnit = calendarBox.height / 20;
            
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            let textColor = NSColor.white
            
            let curDateTime = Date()
            var calendar = Calendar.autoupdatingCurrent
            calendar.minimumDaysInFirstWeek = 4
            let cuttentDateTimeComponet = calendar.dateComponents([.month, .day, .year, .hour, .minute], from: curDateTime)
            
            let monthStringAttrs = [NSFontAttributeName: NSFont(name: "Source Code Pro ExtraLight", size: calendarBox.height/4)!,
                         NSForegroundColorAttributeName: textColor,
                         NSParagraphStyleAttributeName: paragraphStyle]
            let dateFormatter = DateFormatter()
            let monthString = dateFormatter.standaloneMonthSymbols[cuttentDateTimeComponet.month!-1].capitalizingFirstLetter()
            monthString.draw(with: CGRect(x: calendarBox.minX, y: calendarBox.minY, width: calendarBox.width, height: calendarBox.height), options: .usesLineFragmentOrigin, attributes: monthStringAttrs, context: nil)
            
            var weeksString = ""
            var weeksBoldString = ""
            var daysString = ""
            var daysBoldString = ""
            var weekDaysString = ""
            let contOfDaysInMonth = calendar.range(of: .day, in: .month, for: curDateTime)!.count
            for i in 1...contOfDaysInMonth {
                var workDateSourceComponent = DateComponents()
                workDateSourceComponent.year = cuttentDateTimeComponet.year!
                workDateSourceComponent.month = cuttentDateTimeComponet.month!
                workDateSourceComponent.day = i
                let workDate = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.date(from: workDateSourceComponent)
                let workDateComponent = calendar.dateComponents([.weekday, .weekOfYear], from: workDate!)
                if (workDateComponent.weekday! == 2) {
                    weeksString += "\u{2502}   "
                    if (workDateComponent.weekOfYear! < 10) {
                        weeksBoldString += "  " + String(workDateComponent.weekOfYear!) + " "
                    } else {
                        weeksBoldString += "  " + String(workDateComponent.weekOfYear!)
                    }
                    daysString += "\u{2502} "
                    daysBoldString += "  "
                    weekDaysString += "\u{2502} "
                } else {
                    weeksString += "  "
                    weeksBoldString += "  "
                }
                if (i == cuttentDateTimeComponet.day!) {
                    daysString += "  "
                    if (i < 10) {
                        daysBoldString += "0"
                    }
                    daysBoldString += String(i)
                } else {
                    if (i < 10) {
                        daysString += "0"
                    }
                    daysString += String(i)
                    daysBoldString += "  "
                }
                weekDaysString += dateFormatter.shortWeekdaySymbols[workDateComponent.weekday!-1]
                if (i != contOfDaysInMonth) {
                    weeksString += " "
                    weeksBoldString += " "
                    daysString += " "
                    daysBoldString += " "
                    weekDaysString += " "
                }
            }
            let lightStringAttrs = [NSFontAttributeName: NSFont(name: "Source Code Pro ExtraLight", size: calendarBox.height/10)!,
                                    NSForegroundColorAttributeName: textColor,
                                    NSParagraphStyleAttributeName: paragraphStyle]
            let boldStringAttrs = [NSFontAttributeName: NSFont(name: "Source Code Pro Bold", size: calendarBox.height/10)!,
                                   NSForegroundColorAttributeName: textColor,
                                   NSParagraphStyleAttributeName: paragraphStyle]
            weeksString.draw(with: CGRect(x: calendarBox.minX, y: calendarBox.minY, width: calendarBox.width, height: calendarBox.height-vShiftUnit*7.5), options: .usesLineFragmentOrigin, attributes: lightStringAttrs, context: nil)
            weeksBoldString.draw(with: CGRect(x: calendarBox.minX, y: calendarBox.minY, width: calendarBox.width, height: calendarBox.height-vShiftUnit*7.5), options: .usesLineFragmentOrigin, attributes: boldStringAttrs, context: nil)
            daysString.draw(with: CGRect(x: calendarBox.minX, y: calendarBox.minY, width: calendarBox.width, height: calendarBox.height-vShiftUnit*10), options: .usesLineFragmentOrigin, attributes: lightStringAttrs, context: nil)
            daysBoldString.draw(with: CGRect(x: calendarBox.minX, y: calendarBox.minY, width: calendarBox.width, height: calendarBox.height-vShiftUnit*10), options: .usesLineFragmentOrigin, attributes: boldStringAttrs, context: nil)
            weekDaysString.draw(with: CGRect(x: calendarBox.minX, y: calendarBox.minY, width: calendarBox.width, height: calendarBox.height-vShiftUnit*12.5), options: .usesLineFragmentOrigin, attributes: lightStringAttrs, context: nil)
            
            var timeString = ""
            if cuttentDateTimeComponet.hour! < 10 {
                timeString += "0"
            }
            timeString += String(cuttentDateTimeComponet.hour!) + ":"
            if cuttentDateTimeComponet.minute! < 10 {
                timeString += "0"
            }
            timeString += String(cuttentDateTimeComponet.minute!)
            let timeParagraphStyle = NSMutableParagraphStyle()
            timeParagraphStyle.alignment = .right
            let timeStringAttrs = [NSFontAttributeName: NSFont(name: "Source Code Pro ExtraLight", size: calendarBox.height/4)!,
                                    NSForegroundColorAttributeName: textColor,
                                    NSParagraphStyleAttributeName: timeParagraphStyle]
            timeString.draw(with: CGRect(x: 0, y: frame.size.height*0.01, width: frame.size.width*0.99, height: calendarBox.height/3), options: .usesLineFragmentOrigin, attributes: timeStringAttrs, context: nil)
            
            currentImageIdx += 1
            if currentImageIdx == images.count {
                currentImageIdx = 0
            }
        } else {
            super.draw(rect)
        }
    }
    
    override func animateOneFrame() {
        self.needsDisplay = true
    }
    
    override func hasConfigureSheet() -> Bool {
        return false
    }
    
    override func configureSheet() -> NSWindow? {
        return nil
    }
}

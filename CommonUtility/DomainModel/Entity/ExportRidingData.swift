//
//  ExportRidingData.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/26.
//

import Foundation
import Spatial

// ICM 作るところでやるか
class ExportRidingData{
    
    var file: FileHandle?
    var filePath: URL?
    var sample: Int = 0
    let startAt : Date = Date.now
    var isRecording: Bool {
        get{ file != nil}
    }

    func open() {
        let filePathl = ExportRidingData.makeFilePath(fileAlias: "skiData")
        do {
            FileManager.default.createFile(atPath: filePathl.path, contents: nil, attributes: nil)
            let file = try FileHandle(forWritingTo: filePathl)
            var header = ""
            header += "motion time,"
            header += "centerOfMassRelativeDirectionFromSki_x,"
            header += "centerOfMassRelativeDirectionFromSki_y,"
            header += "centerOfMassRelativeDirectionFromSki_z,"
            header += "内倒,"
            header += "スキー方向への加速度,"
            header += "スキー方向への加速度掛けるmillSecond,"
            header += "bodySideTimeStamp,"
            header += "bodySideMotionTimeStamp,"
            header += "bodySideDirectionTimeStamp,"
            header += "fallLineDirectionZVerticalXTrueNorth.eulerAnglesx,"
            header += "fallLineDirectionZVerticalXTrueNorth.eulerAnglesy,"
            header += "fallLineDirectionZVerticalXTrueNorth.eulerAnglesz,"
            header += "谷に落とすのに失敗していることでどれだけ板がズレて減速したがっているか,"
            header += "diffPercentageByAngle,"
            header += "boardSideDirectionTimeStamp,"
            header += "boardSideMotionTimeStamp,"
            header += "time interval"
            header += "\n"
            file.write(header.data(using: .utf8)!)
            self.file = file
            self.filePath = filePathl
        } catch let error {
            print(error)
        }
    }

    func write(_ motion: InclineCoM) {
        guard let file = self.file else { return }
        var text = ""
        let format = DateFormatter()
            format.dateFormat = "HH:mm:ss.SSS"
        format.timeZone = .current
        text += "\(format.string(from: Date(timeIntervalSince1970: motion.boardSideDirectionTimeStamp))),"
        text += "\(motion.centerOfMassRelativeDirectionFromSki.x),"
        text += "\(motion.centerOfMassRelativeDirectionFromSki.y),"
        text += "\(motion.centerOfMassRelativeDirectionFromSki.z),"
        text += "\(motion.gravityHorizontalDistanceFromSkiCenterToCoM.value),"
        text += "\(motion.スキーに垂直な重心の加速度),"
        text += "\(motion.スキーに垂直な方向の加速度掛けるmillSecond),"
        text += "\(motion.bodySideTimeStamp),"
        text += "\(motion.bodySideMotionTimeStamp),"
        text += "\(motion.bodySideDirectionTimeStamp),"
        text += "\(motion.fallLineDirectionZVerticalXTrueNorth.eulerAngles(order: .xyz).angles.x),"
        text += "\(motion.fallLineDirectionZVerticalXTrueNorth.eulerAngles(order: .xyz).angles.y),"
        text += "\(motion.fallLineDirectionZVerticalXTrueNorth.eulerAngles(order: .xyz).angles.z),"
        text += "\(motion.谷に落とすのに失敗していることでどれだけ板がズレて減速したがっているか.f2),"
        text += "\(motion.diffPercentageByAngle),"
        text += "\(motion.boardSideDirectionTimeStamp),"
        text += "\(motion.boardSideMotionTimeStamp),"
        text += "\(motion.timeStamp)"
        print(text)
        text += "\n"
        file.write(text.data(using: .utf8)!)
        sample += 1
    }

    func close() {
        guard let file = self.file else { return }
        file.closeFile()
        print("\(sample) sample")
        self.file = nil
    }

    static func makeFilePath(fileAlias: String) -> URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let filename = formatter.string(from: Date()) + "\(fileAlias).csv"
        let fileUrl = url.appendingPathComponent(filename)
        print(fileUrl.absoluteURL)
        return fileUrl
    }
}


struct CSVExportData{
    let fallLineDirectionZVerticalXTrueNorthx : Double
    let fallLineDirectionZVerticalXTrueNorthy : Double
    let fallLineDirectionZVerticalXTrueNorthz : Double
    // 北を絶対値z0とする現在のスキーの向きと姿勢
    let skiDirectionAbsoluteByNorthx: Double
    let skiDirectionAbsoluteByNorthy: Double
    let skiDirectionAbsoluteByNorthz: Double
    // スキーセンターからスキーに対して垂直な重心の距離と向き Point3D
    let centerOfMassRelativeDirectionFromSkix: Double
    let centerOfMassRelativeDirectionFromSkiy: Double
    let centerOfMassRelativeDirectionFromSkiz: Double
    
    let diffPercentage : Double
    
    var motionTimeStamp: TimeInterval
    var uwbTimeStamp: TimeInterval
    var timeStamp: TimeInterval
    let timeDuration: TimeInterval
    var turnYawingSide : String
    let gravityHorizontalDistanceFromSkiCenterToCoM: Double
    let スマホのyを前方とした重心の位置x: Double
    let スマホのyを前方とした重心の位置y: Double
    let スマホのyを前方とした重心の位置z: Double
    let sterlingAngle: Double
}

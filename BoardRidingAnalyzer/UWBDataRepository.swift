//
//  UWBDataRepository.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/13.
//

import Foundation


class UWBDataRepository: NSObject ,ObservableObject{
    @Published var data : UWBMeasuredData? = nil
    
    
    
    func recieve(data: UWBMeasuredData){
        self.data = data
    }
}

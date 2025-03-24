//
//  DetailScreen.swift
//  Qorvo NI Background
//
//  Created by Mac_Jangyeon on 2/8/25.
//  Copyright © 2025 Apple. All rights reserved.
//
import UIKit

class DeploymentViewController: UIViewController {
    var accessoriesTable: AccessoriesTable?
    let separatorView = SeparatorView(fieldTitle: "Manage Device Connection & Set up Anchor")
    @IBOutlet weak var detailStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailStackView.overrideUserInterfaceStyle = .light
        // accessoriesTable이 전달되었다면, 현재 뷰의 자식 뷰로 추가하여 화면에 표시
        if let table = accessoriesTable {
            detailStackView.insertArrangedSubview(separatorView, at: 0)
            detailStackView.insertArrangedSubview(table, at: 1)
        }
    }
    @IBAction func backToMain(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

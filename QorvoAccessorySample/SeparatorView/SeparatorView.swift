/*
 * @file      SeparatorView.swift
 *
 * @brief     Small View with the device list info. The main Controller shall implement gestures to
 *            handle the device list and views.
 *
 * @author    Decawave Applications
 *
 * @attention Copyright (c) 2021 - 2022, Qorvo US, Inc.
 * All rights reserved
 * Redistribution and use in source and binary forms, with or without modification,
 *  are permitted provided that the following conditions are met:
 * 1. Redistributions of source code must retain the above copyright notice, this
 *  list of conditions, and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *  this list of conditions and the following disclaimer in the documentation
 *  and/or other materials provided with the distribution.
 * 3. You may only use this software, with or without any modification, with an
 *  integrated circuit developed by Qorvo US, Inc. or any of its affiliates
 *  (collectively, "Qorvo"), or any module that contains such integrated circuit.
 * 4. You may not reverse engineer, disassemble, decompile, decode, adapt, or
 *  otherwise attempt to derive or gain access to the source code to any software
 *  distributed under this license in binary or object code form, in whole or in
 *  part.
 * 5. You may not use any Qorvo name, trademarks, service marks, trade dress,
 *  logos, trade names, or other symbols or insignia identifying the source of
 *  Qorvo's products or services, or the names of any of Qorvo's developers to
 *  endorse or promote products derived from this software without specific prior
 *  written permission from Qorvo US, Inc. You must not call products derived from
 *  this software "Qorvo", you must not have "Qorvo" appear in their name, without
 *  the prior permission from Qorvo US, Inc.
 * 6. Qorvo may publish revised or new version of this license from time to time.
 *  No one other than Qorvo US, Inc. has the right to modify the terms applicable
 *  to the software provided under this license.
 * THIS SOFTWARE IS PROVIDED BY QORVO US, INC. "AS IS" AND ANY EXPRESS OR IMPLIED
 *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. NEITHER
 *  QORVO, NOR ANY PERSON ASSOCIATED WITH QORVO MAKES ANY WARRANTY OR
 *  REPRESENTATION WITH RESPECT TO THE COMPLETENESS, SECURITY, RELIABILITY, OR
 *  ACCURACY OF THE SOFTWARE, THAT IT IS ERROR FREE OR THAT ANY DEFECTS WILL BE
 *  CORRECTED, OR THAT THE SOFTWARE WILL OTHERWISE MEET YOUR NEEDS OR EXPECTATIONS.
 * IN NO EVENT SHALL QORVO OR ANYBODY ASSOCIATED WITH QORVO BE LIABLE FOR ANY
 *  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 *  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 *  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 *
 */

import Foundation
import UIKit

class SeparatorView: UIView {
    // Info field
    let titleText: UITextField
      
    init(fieldTitle: String) {
        // Initializing subviews
        titleText = UITextField(frame: .zero)
        titleText.translatesAutoresizingMaskIntoConstraints = false
        titleText.font = .dinNextMedium_s
        titleText.contentVerticalAlignment = .center
        titleText.textAlignment = .left
        titleText.textColor = .black
        titleText.text = fieldTitle
        
        super.init(frame: .zero)
        
        // Add the stack view to the subview
        addSubview(titleText)
        
        // Set up the stack view's constraints
        NSLayoutConstraint.activate([
            titleText.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 22),
            titleText.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        // Set up the parent view's constraints
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: SEPARATOR_VIEW_HEIGHT_CONSTRAINT)
        ])
        
        backgroundColor = .qorvoGray05
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


import SwiftUI

struct SeprateView_Preview: PreviewProvider {
    static var previews: some View {
        // UIKit의 UIView를 SwiftUI로 래핑할 수 있는 UIViewRepresentable
        UIViewPreview {
            // 여기에 우리가 미리보고 싶은 SingleCell 인스턴스를
            // 하나의 뷰처럼 볼 수 있도록 넣어준다
            let cell = SeparatorView(fieldTitle: "asdf")
            // 필요하면 cell.selectAsset(.connecting) 등 상태 설정
            return cell
        }
        .frame(width: 375, height: 80) // 프레임 예시
    }
}


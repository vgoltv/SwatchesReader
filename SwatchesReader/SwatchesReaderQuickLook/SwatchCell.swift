//
//  SwatchCell.swift
//  SwatchesReaderQuickLook
//
//  Created by Viktor Goltvyanytsya on 14.03.2021.
//

import Foundation
import UIKit

class SwatchCell: UITableViewCell {

    let swatchName = UILabel()
    let colorString = UILabel()
    let swatchColor = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        swatchName.translatesAutoresizingMaskIntoConstraints = false
        swatchName.font = UIFont.systemFont(ofSize: 20)
        contentView.addSubview(swatchName)
        
        colorString.translatesAutoresizingMaskIntoConstraints = false
        colorString.font = UIFont.systemFont(ofSize: 15)
        contentView.addSubview(colorString)
        
        swatchColor.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(swatchColor)
        
        swatchColor.layer.borderWidth = 0.5
        swatchColor.layer.borderColor = UIColor.gray.cgColor
        swatchColor.layer.cornerRadius = 5.0;
        
        
        NSLayoutConstraint.activate([
            swatchName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            swatchName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            swatchName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -150),
            swatchName.heightAnchor.constraint(equalToConstant: 30),
            
            colorString.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            colorString.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            colorString.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -150),
            colorString.heightAnchor.constraint(equalToConstant: 30),
            
            swatchColor.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -140),
            swatchColor.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            swatchColor.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            swatchColor.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

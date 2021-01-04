//
//  SwatchesCell.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 11/27/20.
//

import SwiftUI

struct SwatchesCell: View {

    var title: String
    var subtitle: String
    var color: Color
    var gridLayout: Bool

    var body: some View {
        HStack(spacing: 2) {
            
            if ( !self.gridLayout ) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .lineLimit(1)
                        .font(.subheadline)
                    Text(subtitle)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                .frame(minWidth: 0,
                                maxWidth: .infinity,
                                minHeight: 0,
                                maxHeight: .infinity,
                                alignment: .topLeading)
                
                RoundedRectangle(cornerRadius: 10)
                    .addBorder(Color.gray, width: 0.5, cornerRadius: 5)
                    .foregroundColor(self.color)
                    .frame(width:100, height: 50)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .addBorder(Color.gray, width: 0.5, cornerRadius: 5)
                    .foregroundColor(self.color)
                    .frame(height: 50)
            }
            
            Spacer()
        }
        .padding(EdgeInsets(top: 1.0, leading: 0.0, bottom: 1.0, trailing: 0.0))
    }
}

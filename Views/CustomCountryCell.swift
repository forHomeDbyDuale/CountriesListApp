//
//  CustomCountryCell.swift
//  CountriesListApp
//
//  Created by Duale A on 4/29/25.
//

import UIKit

//MARK: - SelfCongiguringCell, any UITableViewCell can conform to this and declare its own reuseidentifier
protocol SelfCongiguringCell: AnyObject {
    static var reuseIdentifier: String { get }
}

final class CountryTableViewCell: UITableViewCell , SelfCongiguringCell {
    static var reuseIdentifier: String = "CountryTableViewCell"

    private let nameRegionLabel = UILabel()
    private let codeLabel = UILabel()
    private let capitalLabel = UILabel()
    private let separator = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        nameRegionLabel.font = .preferredFont(forTextStyle: .headline)
        nameRegionLabel.adjustsFontForContentSizeCategory = true

        codeLabel.font = .preferredFont(forTextStyle: .headline)
        codeLabel.adjustsFontForContentSizeCategory = true
        codeLabel.textAlignment = .right

        capitalLabel.font = .preferredFont(forTextStyle: .subheadline)
        capitalLabel.adjustsFontForContentSizeCategory = true
        capitalLabel.numberOfLines = 1

        separator.backgroundColor = UIColor.systemGray4
        separator.translatesAutoresizingMaskIntoConstraints = false

        let topRow = UIStackView(arrangedSubviews: [nameRegionLabel, codeLabel])
        topRow.axis = .horizontal
        topRow.distribution = .fill
        topRow.alignment = .fill
        topRow.translatesAutoresizingMaskIntoConstraints = false

        let verticalStack = UIStackView(arrangedSubviews: [topRow, capitalLabel])
        verticalStack.axis = .vertical
        verticalStack.spacing = 8
        verticalStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(verticalStack)
        contentView.addSubview(separator)

        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            verticalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func configure(with country: Country) {
        nameRegionLabel.text = "\(country.name), \(country.region)"
        codeLabel.text = country.code
        capitalLabel.text = country.capital
    }
}

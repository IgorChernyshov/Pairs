//
//  ViewController.swift
//  Pairs
//
//  Created by Igor Chernyshov on 10.09.2021.
//

import UIKit

final class ViewController: UIViewController {

	// MARK: - Game Configuration
	private let cardsInRow = 5
	private let cardsInColumn = 4
	private let emojis = ["🍏", "🍐", "🍋", "🍌", "🍉", "🍇", "🍓", "🫐", "🍒", "🍑", "🥭", "🍍", "🥥", "🥝", "🍅", "🍆"]
	private let startingMemorizeTime = 2.0

	// MARK: - Properties
	private var cards = [UIButton]() {
		didSet {
			if cards.isEmpty { showVictoryMessage() }
		}
	}
	private var faceUpCards = [UIButton]()

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		createUI()
		configureCards()
		showAllFaces(seconds: startingMemorizeTime)
	}

	// MARK: - UI Configuration
	private func createUI() {
		guard (cardsInRow * cardsInColumn).isMultiple(of: 2) else {
			fatalError("You have configured wrong amount of cards")
		}

		let cardsView = UIView()
		cardsView.translatesAutoresizingMaskIntoConstraints = false
		cardsView.backgroundColor = .clear
		view.addSubview(cardsView)

		let inset: CGFloat = 16
		NSLayoutConstraint.activate([
			cardsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: inset),
			cardsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
			cardsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset),
			cardsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -inset)
		])
		let buttonWidth = Int(view.frame.width - 2 * inset) / cardsInColumn
		let buttonHeight = Int(view.frame.height - 2 * inset) / cardsInRow

		for row in 0..<cardsInRow {
			for column in 0..<cardsInColumn {
				let card = UIButton(type: .system)
				card.titleLabel?.font = UIFont.systemFont(ofSize: 48)
				card.layer.cornerRadius = 5
				card.layer.masksToBounds = true
				card.layer.borderWidth = 2
				card.layer.borderColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
				card.backgroundColor = #colorLiteral(red: 0, green: 0.8183831573, blue: 0.4869621396, alpha: 1)
				let frame = CGRect(x: column * buttonWidth, y: row * buttonHeight, width: buttonWidth, height: buttonHeight)
				card.frame = frame
				cardsView.addSubview(card)
				cards.append(card)
				card.addTarget(self, action: #selector(cardDidTap), for: .touchUpInside)
			}
		}
	}

	private func configureCards() {
		let numberOfPairs = cards.count / 2
		let emojisToUse = emojis.shuffled().prefix(numberOfPairs)
		cards.shuffle()
		for (index, emoji) in emojisToUse.enumerated() {
			cards[index].setTitle(emoji, for: .disabled)
			cards[numberOfPairs + index].setTitle(emoji, for: .disabled)
		}
	}

	private func showAllFaces(seconds: Double) {
		cards.forEach { $0.isEnabled = false }
		DispatchQueue.main.asyncAfter(deadline: (.now() + seconds)) {
			self.cards.forEach { $0.isEnabled = true }
		}
	}

	// MARK: - Game Logic
	@objc private func cardDidTap(_ card: UIButton) {
		guard faceUpCards.count <= 1 else { return }

		card.isEnabled = false
		faceUpCards.append(card)
		guard faceUpCards.count == 2 else { return }

		let selectedEmoji = faceUpCards[1].title(for: .disabled)
		if faceUpCards.allSatisfy({ $0.title(for: .disabled) == selectedEmoji }) {
			// It is a match
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
				self.cards.removeAll { $0.title(for: .disabled) == selectedEmoji }
				self.faceUpCards.forEach { card in
					UIView.animate(withDuration: 0.25) {
						card.alpha = 0
					}
				}
				self.faceUpCards.removeAll()
			}
		} else {
			// Did not match
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				self.faceUpCards.forEach { $0.isEnabled = true }
				self.faceUpCards.removeAll()
			}
		}
	}

	private func showVictoryMessage() {
		let label = UILabel()
		label.font = UIFont(name: "Chalkduster", size: 72)
		label.text = "Victory!"
		label.transform = CGAffineTransform(scaleX: 0, y: 0)
		label.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(label)
		NSLayoutConstraint.activate([
			label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		])
		UIView.animate(withDuration: 2) {
			label.transform = CGAffineTransform(scaleX: 1, y: 1)
		}
	}
}

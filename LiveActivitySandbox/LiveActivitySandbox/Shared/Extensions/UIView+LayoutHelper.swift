//
//  UIView+LayoutHelper.swift
//  ViewLayoutHelper
//
//  Created by lijia xu on 10/24/21.
//

import UIKit

// MARK: - Layout Related
public extension UIView {
    // MARK: - Models
    enum ViewLayoutSettingModel {
        case topAnchor(to: NSLayoutYAxisAnchor, const: CGFloat = 0.0)
        case bottomAnchor(to: NSLayoutYAxisAnchor, const: CGFloat = 0.0)
        case leadingAnchor(to: NSLayoutXAxisAnchor, const: CGFloat = 0.0)
        case trailingAnchor(to: NSLayoutXAxisAnchor, const: CGFloat = 0.0)
        case widthConstraint(equalTo: NSLayoutDimension)
        case heightConstraint(equalTo: NSLayoutDimension)
        case widthAnchor(const: CGFloat)
        case heightAnchor(const: CGFloat)
    }

    enum LayoutConstraintReturnModel: Hashable {
        case topAnchorConstraint
        case bottomAnchorConstraint
        case leadingAnchorConstraint
        case trailingAnchorConstraint
        case widthAnchorConstraint
        case heightAnchorConstraint
        case centerXConstraint
        case centerYConstraint
    }

    // MARK: - Fill View
    @discardableResult
    func fillSelf(inView view: UIView, withPaddingAround padding: CGFloat = 0.0) -> [LayoutConstraintReturnModel: NSLayoutConstraint] {
        return anchor(
            .topAnchor(to: view.topAnchor, const: padding),
            .leadingAnchor(to: view.leadingAnchor, const: padding),
            .bottomAnchor(to: view.bottomAnchor, const: padding),
            .trailingAnchor(to: view.trailingAnchor, const: padding)
        )
    }

    @discardableResult
    func fillSelfWithAllSafeGuide(inView view: UIView, withPaddingAround padding: CGFloat = 0.0) -> [LayoutConstraintReturnModel: NSLayoutConstraint] {
        let guide = view.safeAreaLayoutGuide
        return anchor(
            .topAnchor(to: guide.topAnchor, const: padding),
            .leadingAnchor(to: guide.leadingAnchor, const: padding),
            .bottomAnchor(to: guide.bottomAnchor, const: padding),
            .trailingAnchor(to: guide.trailingAnchor, const: padding)
        )
    }

    @discardableResult
    func fillSelfWithHorizontalSafeGuide(inView view: UIView, withPaddingAround padding: CGFloat = 0.0) -> [LayoutConstraintReturnModel: NSLayoutConstraint] {
        let guide = view.safeAreaLayoutGuide
        return anchor(
            .topAnchor(to: view.topAnchor, const: padding),
            .leadingAnchor(to: guide.leadingAnchor, const: padding),
            .bottomAnchor(to: view.bottomAnchor, const: padding),
            .trailingAnchor(to: guide.trailingAnchor, const: padding)
        )
    }

    @discardableResult
    func fillSelfWithVerticalSafeGuide(inView view: UIView, withPaddingAround padding: CGFloat = 0.0) -> [LayoutConstraintReturnModel: NSLayoutConstraint] {
        let guide = view.safeAreaLayoutGuide
        return anchor(
            .topAnchor(to: guide.topAnchor, const: padding),
            .leadingAnchor(to: view.leadingAnchor, const: padding),
            .bottomAnchor(to: guide.bottomAnchor, const: padding),
            .trailingAnchor(to: view.trailingAnchor, const: padding)
        )
    }

    // MARK: - Anchor View
    // retuning the constrains in case want to do advance animations
    @discardableResult
    func anchor(_ viewLayoutHelperModels: ViewLayoutSettingModel...) -> [LayoutConstraintReturnModel: NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false

        return viewLayoutHelperModels.reduce(into: [LayoutConstraintReturnModel: NSLayoutConstraint]()) { (sum, nextModel) in
            let constraint: NSLayoutConstraint

            switch nextModel {
            case let .topAnchor(top, paddingTop):
                constraint = topAnchor.constraint(equalTo: top, constant: paddingTop)
                sum[.topAnchorConstraint] = constraint

            case let .bottomAnchor(bottom, paddingBottom):
                constraint = bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom)
                sum[.bottomAnchorConstraint] = constraint

            case let .leadingAnchor(leading, paddingLead):
                constraint = leadingAnchor.constraint(equalTo: leading, constant: paddingLead)
                sum[.leadingAnchorConstraint] = constraint

            case let .trailingAnchor(trailing, paddingTrail):
                constraint = trailingAnchor.constraint(equalTo: trailing, constant: -paddingTrail)
                sum[.trailingAnchorConstraint] = constraint

            case let .widthAnchor(const: widthConstant):
                constraint = widthAnchor.constraint(equalToConstant: widthConstant)
                sum[.widthAnchorConstraint] = constraint

            case let .widthConstraint(equalTo: widthConstraint):
                constraint = widthAnchor.constraint(equalTo: widthConstraint)
                sum[.widthAnchorConstraint] = constraint

            case let .heightAnchor(const: heightConstant):
                constraint = heightAnchor.constraint(equalToConstant: heightConstant)
                sum[.heightAnchorConstraint] = constraint

            case let .heightConstraint(equalTo: heightConstraint):
                constraint = heightAnchor.constraint(equalTo: heightConstraint)
                sum[.heightAnchorConstraint] = constraint
            }

            constraint.isActive = true
        }
    }

    // MARK: - Center View
    @discardableResult
    func centerXAndY(inView view: UIView) -> [LayoutConstraintReturnModel: NSLayoutConstraint] {
        let xConstraint = centerX(inView: view)
        let yConstraint = centerY(inView: view)

        return [.centerXConstraint: xConstraint, .centerYConstraint: yConstraint]
    }

    @discardableResult
    func centerX(inView view: UIView, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false

        let constrain = centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: constant)
        constrain.isActive = true
        return constrain
    }

    @discardableResult
    func centerY(inView view: UIView, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false

        let constrain = centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant)
        constrain.isActive = true
        return constrain
    }
}


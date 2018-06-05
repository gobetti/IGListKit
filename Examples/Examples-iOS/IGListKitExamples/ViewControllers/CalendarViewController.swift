/**
 Copyright (c) 2016-present, Facebook, Inc. All rights reserved.
 
 The examples provided by Facebook are for non-commercial testing and evaluation
 purposes only. Facebook reserves all rights not expressly granted.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import IGListKit
import UIKit

final class CalendarViewController: UIViewController, ListAdapterDataSource {

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: ListCollectionViewLayout(stickyHeaders: false, topContentInset: 0, stretchToEdge: false)
    )

    var months: [Month]! {
        didSet {
            adapter.performUpdates(animated: true)
        }
    }
    private var currentMonth = 0 {
        didSet {
            let calendar = Calendar.current
            let components = DateComponents(year: calendar.component(.year, from: Date()), month: currentMonth)
            let date = calendar.date(from: components)!
            
            months = [
                Month(name: DateFormatter().monthSymbols[currentMonth - 1],
                      days: calendar.range(of: .day, in: .month, for: date)!.count,
                      appointments: [
                        2: ["Hair"],
                        4: ["Nails"],
                        7: ["Doctor appt", "Pick up groceries"],
                        12: ["Call back the cable company", "Find a babysitter"],
                        13: ["Dinner at The Smith"],
                        17: ["Buy running shoes", "Buy a fitbit", "Start running"],
                        20: ["Call mom"],
                        21: ["Contribute to IGListKit"],
                        25: ["Interview"],
                        26: ["Quit running", "Buy ice cream"]
                    ]
                )
            ]
        }
    }
    private var timer: Timer!
    
    deinit {
        timer.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentMonth = 1

        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
        if #available(iOS 10.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.currentMonth = max((strongSelf.currentMonth + 1) % 13, 1)
            }
        } else {
            fatalError("not testing iOS 9")
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    // MARK: ListAdapterDataSource

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return months
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return MonthSectionController()
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }

}

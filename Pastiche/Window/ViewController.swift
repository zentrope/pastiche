//
//  ViewController.swift
//  Pastiche
//
//  Created by Keith Irwin on 5/31/20.
//  Copyright © 2020 Zentrope. All rights reserved.
//

import Cocoa
import ViewKit

class ViewController: NSViewController {

    private var splitView = NSSplitViewController()

    private lazy var masterPane = NSSplitViewItem(viewController: masterView)
    private lazy var detailPane = NSSplitViewItem(viewController: detailView)

    private var masterView = MasterViewController()
    private var detailView = DetailViewController()

    override func loadView() {
        view = NSView(frame: .zero)
            .fill(subview: splitView.view)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        splitView.addSplitViewItem(masterPane)
        splitView.addSplitViewItem(detailPane)

        detailPane.isCollapsed = false

        masterView.detailView = detailView
    }
}

final class MasterViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSFetchedResultsControllerDelegate {

    private lazy var tableView = ViewKitSetup(GridClipTableView()) {
        let column = NSTableColumn()
        column.identifier = PasteTitleCell.identifier
        $0.addTableColumn(column)
        $0.headerView = nil
        $0.usesAutomaticRowHeights = true
        $0.gridStyleMask = []
        $0.usesAlternatingRowBackgroundColors = true
    }

    private lazy var scrollView = ViewKitSetup(NSScrollView()) {
        $0.documentView = tableView
        $0.hasVerticalScroller = true
        $0.borderType = .noBorder
    }

    var detailView: DetailViewController?
    var fetchController: NSFetchedResultsController<Paste>?

    override func loadView() {
        view = NSView()
            .fill(subview: scrollView)
            .minHeight(300)
            .minWidth(250)
            .maxWidth(350)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchController = AppData.shared.pasteFetchController()
        fetchController?.delegate = self

        tableView.dataSource = self
        tableView.delegate = self
        reset()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        reset()
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        // Reset selection to top, assuming you want the latest paste first,
        // or the one you just pasted.
        tableView.selectRowIndexes([0], byExtendingSelection: false)
    }

    func reset() {
        var selection = tableView.selectedRowIndexes
        tableView.reloadData()
        if selection.isEmpty {
            selection.insert(0)
        }
        tableView.selectRowIndexes(selection, byExtendingSelection: false)
    }

    override func keyDown(with event: NSEvent) {
        let selection = tableView.selectedRow
        guard selection >= 0, let paste = fetchController?.fetchedObjects?[selection] else {
            return
        }

        switch Int(event.keyCode) {

        case AppHotKey.RETURN:
            AppEnvironment.shared.send(paste: paste)

        case AppHotKey.ESCAPE:
            NSRunningApplication.current.hide()

        case AppHotKey.DELETE, AppHotKey.FORWARD_DELETE:
            detailView?.set(detail: "")
            AppData.shared.delete(paste)
            tableView.selectRowIndexes([nextSelection(given: selection)], byExtendingSelection: false)

        default:
            //print("key.code: \(Int(event.keyCode))")
            break
        }
    }

    private func nextSelection(given row: Int) -> Int {
        if row == 0 {
            return row
        }
        if row >= (tableView.numberOfRows - 1) {
            return row - 1;
        }
        return row
    }

    // MARK: - Datasource

    func numberOfRows(in tableView: NSTableView) -> Int {
        fetchController?.fetchedObjects?.count ?? 0
    }

    // MARK: - Delegate

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        guard let pasteMO = fetchController?.fetchedObjects?[row] else { return nil }
        if let item = tableView.makeView(withIdentifier: PasteTitleCell.identifier, owner: self) as? PasteTitleCell {
            return item.set(paste: pasteMO)
        }
        return PasteTitleCell().set(paste: pasteMO)
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let selection = tableView.selectedRow

        guard selection >= 0 else {
            detailView?.set(detail: "")
            return
        }

        guard let pasteMO = fetchController?.fetchedObjects?[selection] else { return }
        detailView?.set(detail: pasteMO.value ?? "No paste value found.")
    }

    // MARK: - Cell View

    class PasteTitleCell: NSTableCellView {

        static let identifier = NSUserInterfaceItemIdentifier("PasteTitleCell")

        private var label = ViewKitSetup(NSTextField(wrappingLabelWithString: "…")) {
            $0.maximumNumberOfLines = 1
            $0.lineBreakMode = .byTruncatingTail
            $0.isSelectable = false
        }

        private var paste: Paste?

        convenience init() {
            self.init(frame: .zero)
            fill(subview: label, top: 4, leading: 6, bottom: -4, trailing: -6)
        }

        func set(paste: Paste) -> Self {
            self.paste = paste
            label.stringValue = paste.name ?? "Unknown"
            return self
        }
    }

    // MARK: - Fetched Results Delegate

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        reset()
    }
}

final class DetailViewController: NSViewController {

    private lazy var noWrappedLines = true

    private lazy var scrollView = ViewKitSetup(NSScrollView()) {
        $0.documentView = textView
        $0.hasVerticalScroller = true
        $0.borderType = .noBorder
        $0.focusRingType = .none

        if noWrappedLines {
            $0.hasHorizontalScroller = true
        }
    }

    private lazy var textView = ViewKitSetup(NSTextView()) {
        $0.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        $0.textContainerInset = NSMakeSize(10, 10)
        $0.isEditable = false
        $0.isSelectable = false
        $0.autoresizingMask = [.width, .height]
        $0.isRichText = false

        if noWrappedLines {
            $0.isHorizontallyResizable = true
            $0.textContainer?.widthTracksTextView = false
            let infiniteSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            $0.maxSize = infiniteSize
            $0.textContainer?.size = infiniteSize
        }
    }

    override func loadView() {
        view = NSView()
            .fill(subview: scrollView)
            .minWidth(300)
            .minHeight(300)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.string = "Full paste text goes here."
    }

    func set(detail: String) {
        textView.string = detail
    }
}

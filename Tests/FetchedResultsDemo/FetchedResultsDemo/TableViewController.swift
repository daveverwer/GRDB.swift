import UIKit
import GRDB

class TableViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var players: FetchedResults<Player>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.prefetchDataSource = self
        
        let snapshot = try! DatabasePool.shared.makeSnapshot()
        players = try! Player.all().orderedByScore().fetchResults(snapshot)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        players.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Player", for: indexPath)
        let player = players[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = player.name
        config.secondaryText = "\(player.score)"
        cell.contentConfiguration = config
        return cell
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        players.prefetchResultsAt(indexPaths.lazy.map { $0.row })
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        players.cancelPrefetchResultsAt(indexPaths.lazy.map { $0.row })
    }
}

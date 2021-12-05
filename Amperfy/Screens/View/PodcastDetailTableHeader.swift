import UIKit

class PodcastDetailTableHeader: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var podcastImage: LibraryEntityImage!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    static let frameHeight: CGFloat = 245.0 + margin.top + margin.bottom
    static let margin = UIView.defaultMarginTopElement
    private var podcast: Podcast?
    private var appDelegate: AppDelegate!
    private var rootView: PodcastDetailVC?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        self.layoutMargins = Self.margin
    }
    
    func prepare(toWorkOnPodcast podcast: Podcast?, rootView: PodcastDetailVC? ) {
        guard let podcast = podcast else { return }
        self.podcast = podcast
        self.rootView = rootView
        refresh()
    }
    
    func refresh() {
        guard let podcast = podcast else { return }
        titleLabel.text = podcast.title
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        podcastImage.displayAndUpdate(entity: podcast, via: appDelegate.artworkDownloadManager)
        var infoText = ""
        let episodeCount = podcast.episodes.count
        if episodeCount == 1 {
            infoText += "1 Episode"
        } else {
            infoText += "\(episodeCount) Episodes"
        }
        infoText += " \(CommonString.oneMiddleDot) \(podcast.episodes.reduce(0, {$0 + $1.duration}).asDurationString)"
        infoLabel.text = infoText
        descriptionLabel.text = podcast.depiction
    }

    @IBAction func optionsButtonPressed(_ sender: Any) {
        if let podcast = self.podcast, let rootView = self.rootView {
            let alert = createAlert(forPodcast: podcast)
            alert.setOptionsForIPadToDisplayPopupCentricIn(view: rootView.view)
            rootView.present(alert, animated: true, completion: nil)
        }
    }
    
    func createAlert(forPodcast podcast: Podcast) -> UIAlertController {
        let alert = UIAlertController(title: podcast.title, message: nil, preferredStyle: .actionSheet)
        if appDelegate.persistentStorage.settings.isOnlineMode {
            alert.addAction(UIAlertAction(title: "Download", style: .default, handler: { _ in
                podcast.cachePlayables(downloadManager: self.appDelegate.playableDownloadManager)
            }))
        }
        if podcast.hasCachedPlayables {
            alert.addAction(UIAlertAction(title: "Remove from cache", style: .default, handler: { _ in
                self.appDelegate.playableDownloadManager.removeFinishedDownload(for: podcast.playables)
                self.appDelegate.library.deleteCache(of: podcast)
                self.appDelegate.library.saveContext()
                if let rootView = self.rootView {
                    rootView.tableView.reloadData()
                }
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.pruneNegativeWidthConstraintsToAvoidFalseConstraintWarnings()
        return alert
    }
    
}

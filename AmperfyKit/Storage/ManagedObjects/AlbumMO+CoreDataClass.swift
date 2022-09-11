//
//  AlbumMO+CoreDataClass.swift
//  AmperfyKit
//
//  Created by Maximilian Bauer on 31.12.19.
//  Copyright (c) 2019 Maximilian Bauer. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import CoreData

@objc(AlbumMO)
public final class AlbumMO: AbstractLibraryEntityMO {

    static func getFetchPredicateForAlbumsWhoseSongsHave(artist: Artist) -> NSPredicate {
        return NSPredicate(format: "SUBQUERY(songs, $song, $song.artist == %@) .@count > 0", artist.managedObject.objectID)
    }
    
    static var releaseYearSortedFetchRequest: NSFetchRequest<AlbumMO> {
        let fetchRequest: NSFetchRequest<AlbumMO> = AlbumMO.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(AlbumMO.year), ascending: true),
            NSSortDescriptor(key: #keyPath(AlbumMO.name), ascending: true)
        ]
        return fetchRequest
    }
    
    static var ratingSortedFetchRequest: NSFetchRequest<AlbumMO> {
        let fetchRequest: NSFetchRequest<AlbumMO> = AlbumMO.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(AlbumMO.rating), ascending: false),
            NSSortDescriptor(key: Self.identifierKeyString, ascending: true, selector: #selector(NSString.localizedStandardCompare)),
            NSSortDescriptor(key: #keyPath(AlbumMO.id), ascending: true, selector: #selector(NSString.localizedStandardCompare))
        ]
        return fetchRequest
    }
    
    static var recentlyAddedSortedFetchRequest: NSFetchRequest<AlbumMO> {
        let fetchRequest: NSFetchRequest<AlbumMO> = AlbumMO.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(AlbumMO.recentlyAddedIndex), ascending: true),
            NSSortDescriptor(key: Self.identifierKeyString, ascending: true, selector: #selector(NSString.localizedStandardCompare)),
            NSSortDescriptor(key: #keyPath(AlbumMO.id), ascending: true, selector: #selector(NSString.localizedStandardCompare))
        ]
        return fetchRequest
    }

}

extension AlbumMO: CoreDataIdentifyable {
    
    static var identifierKey: KeyPath<AlbumMO, String?> {
        return \AlbumMO.name
    }
    
    func passOwnership(to targetAlbum: AlbumMO) {
        let songsCopy = songs?.compactMap{ $0 as? SongMO }
        songsCopy?.forEach{
            $0.album = targetAlbum
        }
    }
    
}

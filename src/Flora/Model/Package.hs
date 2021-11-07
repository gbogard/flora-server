{-# LANGUAGE QuasiQuotes     #-}
{-# LANGUAGE OverloadedLists #-}
module Flora.Model.Package where

import Data.Aeson
import Data.Text (Text)
import Data.Time (UTCTime)
import Data.UUID
import Database.PostgreSQL.Entity                           
import Database.PostgreSQL.Entity.Types                     
import Database.PostgreSQL.Simple (Only (Only))             
import Database.PostgreSQL.Simple.FromField (FromField (..))
import Database.PostgreSQL.Simple.FromRow (FromRow (..))    
import Database.PostgreSQL.Simple.ToField (ToField (..))    
import Database.PostgreSQL.Simple.ToRow (ToRow (..))        
import Database.PostgreSQL.Transact (DBT)                   
import GHC.Generics
import qualified Distribution.SPDX.License as SPDX

import Flora.Model.Package.Orphans ()
import Flora.Model.User

newtype PackageId = PackageId { getPackageId :: UUID }
  deriving stock (Generic)
  deriving (Eq, Show, FromField, ToField, FromJSON, ToJSON)
    via UUID

data Package = Package
  { packageId :: PackageId
  , name :: Text
  , synopsis :: Text
  , license :: SPDX.License
  , ownerId :: UserId
  , createdAt :: UTCTime
  , updatedAt :: UTCTime
  }
  deriving stock (Eq, Show,Generic)
  deriving anyclass (FromRow, ToRow)
  deriving (Entity)
    via (GenericEntity '[TableName "packages"] Package)

createPackage :: Package -> DBT IO ()
createPackage package = insert @Package package

getPackageById :: PackageId -> DBT IO (Maybe Package)
getPackageById packageId = selectById @Package (Only packageId)

getPackageByName :: Text -> DBT IO (Maybe Package)
getPackageByName name = selectOneByField [field| package_name |] (Only name)

deletePackage :: PackageId -> DBT IO ()
deletePackage packageId = delete @Package (Only packageId)

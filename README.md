# CAPM Audit Logging with @changelog Annotation

## Overview
This project is an SAP BTP CAP (Cloud Application Programming) Model-based application that implements an audit logging feature using the `@changelog` annotation. The application consists of an entity `BOOK` in the database (`db/schema.cds`) and a service `CatalogService` (`srv/cat-service.cds`).

The `@changelog` annotation is applied to the `ID` and `TEMP` fields in the `Books` entity to enable automatic change tracking. This generates additional database artifacts that facilitate audit logging.

## Project Structure

```
CAPM_Auditlogging
│-- README.md
│-- app/
│   │-- book/
│   │   │-- README.md
│   │   │-- annotations.cds
│   │   │-- package-lock.json
│   │   │-- package.json
│   │   │-- ui5-deploy.yaml
│   │   │-- ui5.yaml
│   │   │-- webapp/
│   │   │   │-- Component.js
│   │   │   │-- i18n/
│   │   │   │   `-- i18n.properties
│   │   │   │-- index.html
│   │   │   │-- manifest.json
│   │   │   `-- test/
│   │   │       │-- flpSandbox.html
│   │   │       │-- integration/
│   │   │       │   │-- FirstJourney.js
│   │   │       │   │-- opaTests.qunit.html
│   │   │       │   │-- opaTests.qunit.js
│   │   │       │   `-- pages/
│   │   │       │       │-- BooksList.js
│   │   │       │       `-- BooksObjectPage.js
│   │   │       │-- testsuite.qunit.html
│   │   │       `-- testsuite.qunit.js
│   │   `-- xs-app.json
│   `-- services.cds
│-- db/
│   │-- schema.cds
│   │-- src/
│   `-- undeploy.json
│-- gen/
│   │-- db/
│   │   │-- CatalogService.Books.hdbview
│   │   │-- CatalogService.Books_drafts.hdbtable
│   │   │-- CatalogService.ChangeView.hdbview
│   │   │-- CatalogService.DraftAdministrativeData.hdbview
│   │   │-- DRAFT.DraftAdministrativeData.hdbtable
│   │   │-- VASU.BOOK.hdbtable
│   │   │-- sap.changelog.ChangeLog.hdbtable
│   │   │-- sap.changelog.ChangeView.hdbview
│   │   │-- sap.changelog.Changes.hdbtable
│   │   `-- undeploy.json
│   `-- srv/
│       │-- package-lock.json
│       │-- package.json
│       `-- srv/
│           │-- _i18n/
│           │   `-- i18n.json
│           │-- cat-service.js
│           │-- csn.json
│           `-- odata/
│               `-- v4/
│                   `-- CatalogService.xml
│-- mta.yaml
│-- package-lock.json
│-- package.json
│-- srv/
│   │-- cat-service.cds
│   `-- cat-service.js
`-- xs-security.json
```

## Database Schema

`db/schema.cds` defines the entity `BOOK`:

```cds
namespace VASU;

entity BOOK {
  key ID   : Integer;
      TEMP : Integer;
}
```

## Service Definition

`srv/cat-service.cds` defines the service:

```cds
using VASU from '../db/schema';

service CatalogService {
    @odata.draft.enabled
    entity Books as projection on VASU.BOOK;
}

annotate CatalogService.Books with {
    ID   @changelog;
    TEMP @changelog;
}
```

## Audit Logging with @changelog

### How it Works
The `@changelog` annotation enables audit logging for the specified fields. This means:
1. Any changes to the `ID` and `TEMP` fields are recorded.
2. SAP CAP automatically generates additional tables and views for tracking changes.

### Generated Files
As a result of the `@changelog` annotation, the following files are generated under the `gen/db` directory:

- **`sap.changelog.ChangeLog.hdbtable`** – Stores the change log history.
- **`sap.changelog.ChangeView.hdbview`** – A view to query change logs.
- **`sap.changelog.Changes.hdbtable`** – Records individual changes.
- **`CatalogService.ChangeView.hdbview`** – Change tracking specific to the `Books` entity.

Additionally, the draft-enabled service results in:
- **`CatalogService.Books_drafts.hdbtable`** – Stores draft versions of `Books`.
- **`DRAFT.DraftAdministrativeData.hdbtable`** – Manages draft metadata.

## Fiori UI Integration

The Fiori List Report application (`app/book/`) uses annotations to display data. The `annotations.cds` file contains:

```cds
using CatalogService as service from '../../srv/cat-service';

annotate service.Books with @(
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Label : 'ID',
                Value : ID,
            },
            {
                $Type : 'UI.DataField',
                Label : 'TEMP',
                Value : TEMP,
            },
        ],
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneratedFacet1',
            Label : 'General Information',
            Target : '@UI.FieldGroup#GeneratedGroup',
        },
    ],
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : 'ID',
            Value : ID,
        },
        {
            $Type : 'UI.DataField',
            Label : 'TEMP',
            Value : TEMP,
        },
    ],
);
```

### UI Features
- **List Report**: Displays all books with ID and TEMP fields.
- **Object Page**: Displays details of a book entry.
- **Audit Logs**: The logs can be accessed via `ChangeView.hdbview`.

## Deployment and Configuration

### Prerequisites
- SAP Business Technology Platform (BTP) with CAPM enabled.
- SAP HANA database.
- Node.js and npm installed.
- UI5 tooling installed (`npm install -g @ui5/cli`).

### Deployment Steps
1. Install dependencies:
   ```sh
   npm install
   ```
2. Build and deploy database artifacts:
   ```sh
   cds deploy --to hana
   ```
3. Run the CAP application:
   ```sh
   cds watch
   ```
4. Deploy the Fiori UI:
   ```sh
   ui5 build --all
   ```
5. Deploy the MTA application to BTP:
   ```sh
   mbt build
   cf push
   ```

## Conclusion
This project showcases how to enable audit logging using the `@changelog` annotation in SAP CAPM. The generated change logs allow tracking of modifications to critical fields, ensuring transparency and compliance. The integration with a Fiori UI provides a seamless user experience for viewing and managing data.


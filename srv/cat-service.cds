using VASU from '../db/schema';

service CatalogService {
    @odata.draft.enabled
    entity Books as projection on VASU.BOOK;
}

annotate CatalogService.Books with {
    ID   @changelog;
    TEMP @changelog;

}

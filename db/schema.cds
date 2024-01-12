//Recuperado
namespace com.logali;

using {
    cuid,
    managed
} from '@sap/cds/common';


define type Name : String(50);

define type Address {
    Street     : String;
    City       : String;
    State      : String(2);
    PostalCode : String(5);
    Country    : String(3);
};

context materials {
    entity Products : cuid, managed {
        Name             : localized String not null;
        Description      : localized String;
        ImageUrl         : String;
        ReleaseDate      : DateTime default $now;
        DiscontinuedDate : DateTime;
        Price            : Decimal(16, 2);
        Height           : type of Price; //Decimal(16, 2);
        Width            : Decimal(16, 2);
        Depth            : Decimal(16, 2);
        Quantity         : Decimal(16, 2);
        Supplier         : Association to one sales.Suppliers;
        UnitOfMeasure    : Association to UnitOfMeasures;
        Currency         : Association to Currencies;
        DimensionUnit    : Association to DimensionUnits;
        Category         : Association to Categories;

        SalesData        : Association to many sales.SalesData
                               on SalesData.Product = $self;

        Reviews          : Association to many ProductReview
                               on Reviews.Product = $self;

        StockAvailability: Association to StockAvailability;
    }

    entity Categories {
        key ID   : String(1);
            Name : localized String;
    }

    entity StockAvailability {
        key ID          : Integer;
            Description : localized String;
            Product     : Association to Products;
    }

    entity Currencies {
        key ID          : String(3);
            Description : localized String;
    }

    entity UnitOfMeasures {
        key ID          : String(2);
            Description : localized String;
    }

    entity DimensionUnits {
        key ID          : String(2);
            Description : String;
    }


    entity ProductReview : cuid, managed {
        Name    : String;
        Rating  : Integer;
        Comment : String;
        Product : Association to Products;
    }

    entity SelProducts   as select from Products;
    entity ProjProducts  as projection on Products;

    entity ProjProducts2 as
        projection on Products {
            *
        };

    entity ProjProducts3 as
        projection on Products {
            ReleaseDate,
            Name
        };

    extend Products with {
        PriceCondition     : String(2);
        PriceDetermination : String(3)
    }

}

context sales {
    entity Orders : cuid {
        Data     : Date;
        Customer : String;
        Items    : Composition of many OrderItems
                       on Items.Order = $self;
    }

    entity OrderItems : cuid {
        Order    : Association to Orders;
        Product  : Association to materials.Products;
        Quantity : Integer;
    }

    entity Suppliers : cuid, managed {
        Name    : materials.Products:Name; //String;
        Address : Address;
        Email   : String;
        Phone   : String;
        Fax     : String;
        Product : Association to many materials.Products
                      on Product.Supplier = $self;
    }

    entity Months {
        key ID               : String(2);
            Description      : localized String;
            ShortDescription : localized String(3);
    }

    entity SelProducts1 as
        select from materials.Products {
            *
        };

    entity SelProducts2 as
        select from materials.Products {
            Name,
            Price,
            Quantity
        };

    entity SelProducts3 as
        select from materials.Products as a
        left join materials.ProductReview as b
            on a.Name = b.Name
        {
            b.Rating,
            b.Name,
            sum(Price) as TotalPrice
        }
        group by
            b.Rating,
            b.Name
        order by
            b.Rating;

    entity SalesData : cuid, managed {
        DeliveryDate  : DateTime;
        Revenue       : Decimal(16, 2);
        Product       : Association to materials.Products;
        Currency      : Association to materials.Currencies;
        DeliveryMonth : Association to Months;
    }

}


context reports {

    entity AverageRating as
        select from logali.materials.ProductReview {
            Product.ID  as ProductId,
            avg(Rating) as AverageRating : Decimal(16, 2)
        }
        group by
            Product.ID;


entity Products      as
        select from logali.materials.Products
        mixin {
            ToStockAvailibilty : Association to logali.materials.StockAvailability
                                     on ToStockAvailibilty.ID = $projection.StockAvailability;
            ToAverageRating    : Association to AverageRating
                                     on ToAverageRating.ProductId = ID;
        }

        into {
            *,
            ToAverageRating.AverageRating as Rating,
            case
                when
                    Quantity >= 8
                then
                    3
                when
                    Quantity > 0
                then
                    2
                else
                    1
            end                           as StockAvailability : Integer,
            ToStockAvailibilty
        }

}

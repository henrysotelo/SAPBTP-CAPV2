const cds = require("@sap/cds");
const { Orders } = cds.entities("com.training");

module.exports = (srv) => {

    //Read
    srv.on("READ", "GetOrders", async (req) => {

        if (req.data.ClientEmail !== undefined) {
            return await SELECT.from`com.training.Orders`.where`ClientEmail = ${req.data.ClientEmail}`;
        }
        return await SELECT.from(Orders);
    });


    srv.after("READ", "GetOrders", (data) => {
        return data.map((order) => (order.Reviewed = true));
    });


    //Create
    srv.on("CREATE", "CreateOrder", async (req) => {
        let returnData = await cds.transaction(req).run(INSERT.into(Orders).entities({
            ClientEmail: req.data.ClientEmail,
            FirstName: req.data.FirstName,
            LastName: req.data.LastName,
            CreatedOn: req.data.CreatedOn,
            Reviewed: req.data.Reviewed,
            Approved: req.data.Approved,
        })
        ).then((resolve, reject) => {
            console.log("Resolve", resolve);
            console.log("Reject", reject);

            if (typeof resolve !== "undefined") {
                return req.data;
            } else {
                req.error(409, "Record Not Inserted");
            }

        }).catch((err) => {
            console.log(err);
            req.error(err.code, err.message);
        });
        console.log("Before End", returnData);
        return returnData;
    });


    srv.before("CREATE", "CreateOrder", (req) => {
        req.data.CreatedOn = new Date().toISOString().slice(0, 10);
        return req;
    });


    //Update
    srv.on("UPDATE", "UpdateOrder", async (req) => {
        let returnData = await cds.transaction(req).run(
            [
                UPDATE(Orders, req.data.ClientEmail).set({
                    FirstName: req.data.FirstName,
                    LastName: req.data.LastName,
                })
            ]
        ).then((resolve, reject) => {
            console.log("Resolve", resolve);
            console.log("Reject", reject);

            if (resolve[0] == 0) {
                req.error(409, "Record Not Found");
            };

        }).catch((err) => {
            console.log(err);
            req.error(err.code, err.message);
        });
        console.log("Before end", returnData);
        return returnData;
    });


    //Delete
    srv.on("DELETE", "DeleteOrder", async (req) => {

        let returnData = await cds.transaction(req).run(
            DELETE.from(Orders).where({
                ClientEmail: req.data.ClientEmail,
            })
        ).then((resolve, reject) => {
            console.log("Resolve", resolve);
            console.log("Reject", reject);

            if (resolve !== 1) {
                req.error(409, "Record Not Found");
            }

        }).catch((err) => {
            console.log(err);
            req.error(err.code, err.message);

        });
        console.log("Before End", returnData);
        return await returnData;
    });


    //Function
    srv.on("getClientTaxRate", async (req) => {
        //No server side-effect
        const { clientEmail } = req.data;
        const db = srv.transaction(req);

        const result =
            await db.read(Orders, ["Country_code"]).where({ ClientEmail: clientEmail });

        console.log(result[0]);

        switch (result[0].Country_code) {
            case 'ES':
                return 21.5;
            case 'UK':
                return 24.6;
            default:
                break;
        }
    });

    //Action 
    srv.on("cancelOrder", async (req) => {
        const { clientEmail } = req.data;
        const db = srv.transaction(req);

        const resultsRead = 
            await db.read(Orders, ["FirstName", "LastName", "Approved"])
                    .where({ ClientEmail: clientEmail });

        let returnOrder = {
            status : "",
            message : ""
        };

        console.log(clientEmail);
        console.log(resultsRead);
        
        if(resultsRead[0].Approved == false ) {
            const resultsUpdate 
            = await db.update(Orders).set({Status : 'C'}).where({ClientEmail: clientEmail});

            returnOrder.status = "Succeeded";    
            returnOrder.message 
                = `The order placed by ${resultsRead[0].FirstName} ${resultsRead[0].LastName} whas canceled`;      
        } else{

            returnOrder.status = "Failed";    
            returnOrder.message 
                = `The order placed by ${resultsRead[0].FirstName} ${resultsRead[0].LastName} whas Not  canceled becouse was alrealdy approved`;      
        }
        console.log("Action cancelOrder executed");
        return returnOrder;
    });
};
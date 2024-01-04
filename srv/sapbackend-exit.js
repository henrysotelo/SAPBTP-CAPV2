const cds = require("@sap/cds");

module.exports = cds.service.impl(async function(){
    const { Incidents } = this.entities;
    const sapbackend = await cds.connect.to("sapbackend");
    this.on("READ", Incidents, async (req) => {
     return await sapbackend.tx(req).send({
            query : req.query,
            headers : {
                Authorization : "Basic c2FwdWk1OnNhcHVpNQ=="
            }
        });
    } );
});
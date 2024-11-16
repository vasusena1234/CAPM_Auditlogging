const cds = require('@sap/cds');

module.exports = cds.service.impl(async function(){
    this.before('CREATE', 'Books', (req) => {
        console.log(req);
    });
});
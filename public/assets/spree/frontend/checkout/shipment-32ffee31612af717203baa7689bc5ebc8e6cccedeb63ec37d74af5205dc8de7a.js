function ShippingTotalManager(t){this.input=t,this.shippingMethods=this.input.shippingMethods,this.shipmentTotal=this.input.shipmentTotal,this.orderTotal=this.input.orderTotal,this.formatOptions={symbol:this.shipmentTotal.data("currency"),decimal:this.shipmentTotal.attr("decimal-mark"),thousand:this.shipmentTotal.attr("thousands-separator"),precision:2}}ShippingTotalManager.prototype.calculateShipmentTotal=function(){var t=$(this.shippingMethods).filter(":checked");return this.sum=0,$.each(t,function(t,i){this.sum+=this.parseCurrencyToFloat($(i).data("cost"))}.bind(this)),this.readjustSummarySection(this.parseCurrencyToFloat(this.orderTotal.html()),this.sum,this.parseCurrencyToFloat(this.shipmentTotal.html()))},ShippingTotalManager.prototype.parseCurrencyToFloat=function(t){return accounting.unformat(t,this.formatOptions.decimal)},ShippingTotalManager.prototype.readjustSummarySection=function(t,i,o){var a=t+(i-o);return this.shipmentTotal.html(accounting.formatMoney(i,this.formatOptions)),this.orderTotal.html(accounting.formatMoney(a,this.formatOptions))},ShippingTotalManager.prototype.bindEvent=function(){this.shippingMethods.change(function(){return this.calculateShipmentTotal()}.bind(this))},Spree.ready(function(t){return new ShippingTotalManager({orderTotal:t("#summary-order-total"),shipmentTotal:t('[data-hook="shipping-total"]'),shippingMethods:t('input[data-behavior="shipping-method-selector"]')}).bindEvent()});
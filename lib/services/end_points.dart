// const apiEndPoint = "https://staging.pointifypos.com/";
const apiEndPoint = "https://api.pointifypos.com/";

class EndPoints {
  //AUTH
  static const register = "${apiEndPoint}auth/register";
  static const login = "${apiEndPoint}auth/login";
  static const requestpassword = "${apiEndPoint}auth/admin/request/password";
  static const resetpassword = "${apiEndPoint}auth/admin/reset/password";
  static const admin = "${apiEndPoint}auth/admin/";
  //SHOP
  static const shop = "${apiEndPoint}shop/";
  static const deleteshopdata = "${apiEndPoint}shop/data/";
  static const getadminshop = "${apiEndPoint}shop/admin/";
  static const shoptypes = "${apiEndPoint}shop/category/";
  static const transfer = "${apiEndPoint}transfer/shop/transfer";
  static const transferfilter = "${apiEndPoint}transfer/filter";
  static const redeemusage = "${shop}redeem/usage";
  //USER
  static const profile = "${apiEndPoint}admin/";
  static const lastseen = "${apiEndPoint}analysis/update/user/lastseen";
  static const sendverificationemail = "${profile}sendverificationemail";
  static const setting = "${apiEndPoint}setting/global/all";
  static const attendants = "${apiEndPoint}attendants/";
  static const attendantsfilter = "${apiEndPoint}attendants/shop/filter";

  //PRODUCT
  static const productcategories = "${apiEndPoint}product/category";
  static const products = "${apiEndPoint}product/";
  static const productCount = "${apiEndPoint}counts";
  static const productimport = "${products}import/products";
  static const producttransferimport = "${products}transfer/products";
  static const shopproductCount = "${apiEndPoint}counts/shop";
  static const badstock = "${apiEndPoint}badstock";
  static const summarybadstock = "${apiEndPoint}badstock/summary";
  static const countsproduct = productCount;
  static const badstockfilter = "${apiEndPoint}badstock/product/filter";
  static const stockreport = "${products}stockreport/";
  static const updateproductimages = "${products}images/";

  //measures
  static const measures = "${apiEndPoint}measures/";

  //ANALYSIS
  static const analysisPath = "${apiEndPoint}analysis/stockanalysis/";
  static const analysis = "${apiEndPoint}analysis/stockanalysis/";
  static const analysisnet = "${apiEndPoint}analysis/netprofit/";
  static const analysismonthly = "${apiEndPoint}sales/product/month/analysis/";
  static const analysisproducts =
      "${apiEndPoint}sales/summary/month/analysis/product/";
  static const salesreport = "${apiEndPoint}analysis/report/sales";
  static const profitsummary = "${apiEndPoint}analysis/profits/summary";
  static const debtor = "${apiEndPoint}customers/customers/debtors";
  static const debtorexcel = "${apiEndPoint}customers/customers/debtors/excel";
  static const purchasesreport = "${apiEndPoint}analysis/report/purchases";
  static const backupnow = "${apiEndPoint}analysis/backup/download";

  // SUPPLIERS
  static const supplier = "${apiEndPoint}suppliers/";
  static const supplies = supplier;

  // PURCHASE
  static const purchase = "${apiEndPoint}purchases/";
  static const productpurchase = "${apiEndPoint}purchases/product/filter";
  static const purchasefilter =
      "${apiEndPoint}purchases/product/month/analysis";
  static const purchasepayment = "${apiEndPoint}payments/recordPurchasePayment";
  static const purchasepayments = "${apiEndPoint}payments";
  static const purchasereturn = "${apiEndPoint}purchasereturns/";
  static const purchasereturnsupplier =
      "${apiEndPoint}purchasereturns/supplier";

  //SALES
  static const sales = "${apiEndPoint}sales/";
  static const salesfilter = "${sales}filter";
  static const productsalesfilter = "${sales}product/filter";
  static const salereturn = "${apiEndPoint}salereturns/";
  static const salereturnsfilter = "${salereturn}filter";
  static const payments = "${apiEndPoint}payments";
  static const salepayment = "$payments/recordSalePayment";
  static const voidreceipt = "${sales}void/sale";
  static const productsales = "${sales}products/reports";
  static const discountsales = "${sales}discount/reports";

  //CUSTOMER
  static const customer = "${apiEndPoint}customers/";
  static const customerimport = "${apiEndPoint}customers/import/customers";
  static const customerverify = "${customer}verify/";
  static const customerpayments = "${customer}payments";

  //CASHFLOW
  static const cashflowcategory = "${apiEndPoint}cashflowcategory/";
  static const cashflowcategoryshop = "${cashflowcategory}shop/";
  static const deleteBank = "${cashflowcategory}deletebank";

  static const cashflow = "${apiEndPoint}cashflow/";
  static const cashflowtransactions = "${cashflow}transactions/";
  static const cashflowcategorytransactions =
      "${cashflowtransactions}category/";
  static const cashflowsummary = "${cashflow}shop/cashflow";
  static const cashflowcategrybyshop = "${cashflow}total/category";
  static const createbank = "${cashflow}bank/";

  //BANK
  static const bank = "${apiEndPoint}bank/";
  static const banks = "${bank}list";
  static const banktransactions = "${bank}transactions";

  //EPENSES
  static const expense = "${apiEndPoint}expenses/";
  static const expensefilter = "${expense}filter";
  static const expensecategory = "${apiEndPoint}expensescategory";
  static const expensecategorytotal = "$expense/total/category";
  static const expensecategorytransactions = "${expense}transactions";

  //ATTENDANTS

  static const getattendants = "${apiEndPoint}attendants/";
  static const getattendantslogin = "${apiEndPoint}attendants/login";

  //PACKAGES
  static const packages = "${apiEndPoint}packages/";

  //SUBSCRIPTIONS
  static const subscriptions = "${apiEndPoint}subscriptions";
  static const updatestripesubscriptions =
      "${apiEndPoint}subscriptions/stripe/updateAfterStripeSuccessPayment";
  static const subscriptionPayment = "${apiEndPoint}payment/subscribe/";
  static const subscriptionPaymentconfirm =
      "${apiEndPoint}payment/subscribe/confirm";

  //STRIPE

  var stripeBase = "https://api.stripe.com/v1";
  var connectStripeBase = "$apiEndPoint/stripe/connect/";
  static const createIntentStripeUrl = "$apiEndPoint/stripe/createIntent/";

  //ORDERS
  static const order = "${apiEndPoint}orders/";
  static const awardstransactions = "${apiEndPoint}payments/awards/";
}

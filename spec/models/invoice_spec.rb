require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe "validations" do
    it { should validate_presence_of :status }
    it { should validate_presence_of :customer_id }
  end
  describe "relationships" do
    it { should belong_to :customer }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:merchants).through(:items) }
    it { should have_many :transactions}
  end
  describe "instance methods" do
    it "total_revenue" do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 9, unit_price: 10, status: 2)
      @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 1, unit_price: 10, status: 1)

      expect(@invoice_1.total_revenue).to eq(100)
    end
    describe 'adjust_price' do
      it "adjusts the price of the invoice item to relfect the applied discount" do
        @merchant1 = Merchant.create!(name: 'Hair Care')
        @merchant2 = Merchant.create!(name: 'Tester')
        @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
        @item_2 = Item.create!(name: "This one should show up", description: "Please show up!", unit_price: 20, merchant_id: @merchant1.id, status: 1)
        @item_3 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
        @item_99 = Item.create!(name: "Merchant2 Item", description: "This shouldn't show up", unit_price: 200, merchant_id: @merchant2.id)
        @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
        @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
        @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 10, unit_price: 10, status: 2)
        @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 5, unit_price: 20, status: 1)
        @ii_3 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_3.id, quantity: 1, unit_price: 15, status: 1)
        @ii_99 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_99.id, quantity: 100, unit_price: 200, status: 1)
        @discount1 = Discount.create!(percentage_discount: 0.50, quantity_threshold: 5, merchant_id: @merchant1.id)
        @discount2 = Discount.create!(percentage_discount: 0.75, quantity_threshold: 10, merchant_id: @merchant1.id)
        @discount3 = Discount.create!(percentage_discount: 0.85, quantity_threshold: 5000, merchant_id: @merchant1.id)

        @invoice_1.adjust_price

        @ii_1.reload
        @ii_2.reload
        @ii_3.reload
        @ii_99.reload

        expect(@ii_1.discounted_price).to eq(2.5)
        expect(@ii_2.discounted_price).to eq(10)
        expect(@ii_3.discounted_price).to eq(15)
        expect(@ii_99.discounted_price).to eq(200)
      end
    end
    it "total_discounted_revenue" do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 10, unit_price: 10, status: 2)
      @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 1, unit_price: 20, status: 1)
      @discount = Discount.create!(percentage_discount: 0.50, quantity_threshold: 5, merchant_id: @merchant1.id)

      expect(@invoice_1.total_revenue).to eq(120)
      expect(@invoice_1.total_discounted_revenue).to eq(70)
      @ii_1.reload
      @ii_11.reload
      expect(@ii_1.discounted_price).to eq(5)
      expect(@ii_11.discounted_price).to eq(20)
    end
  end
end

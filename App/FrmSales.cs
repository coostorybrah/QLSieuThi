using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace QLSieuThi
{
    public partial class FrmSales : Form
    {
        private BindingList<CartItem> cart = new BindingList<CartItem>();
        private int oldQuantity;

        public FrmSales()
        {
            InitializeComponent();
        }

        private void FrmSales_Load(object sender, EventArgs e)
        {
            UpdateTotal();
            btnCheckout.Enabled = cart.Count > 0;

            SetupCartGrid();

            // DELEGATES
            txtBarcode.KeyDown += txtBarcode_KeyDown;

            cart.ListChanged += (s, ev) =>
            {
                btnCheckout.Enabled = cart.Count > 0;
                UpdateTotal();
            };

            dgvCart.CellBeginEdit += dgvCart_CellBeginEdit;
            dgvCart.CellEndEdit += dgvCart_CellEndEdit;
            dgvCart.KeyDown += dgvCart_KeyDown;
            dgvCart.CellContentClick += dgvCart_CellContentClick;
        }
        protected override void OnActivated(EventArgs e)
        {
            base.OnActivated(e);
            txtBarcode.Focus();
        }

        // BASIC FUNCTIONS
        private void RefreshCart()
        {
            dgvCart.CommitEdit(DataGridViewDataErrorContexts.Commit);
            dgvCart.Refresh();
        }

        private void UpdateTotal()
        {
            decimal total = cart.Sum(x => x.Total);
            lblTotalValue.Text = total.ToString("N0") + " ₫";
        }


        // BARCODE LOGIC
        private void txtBarcode_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                AddProductToCart(txtBarcode.Text.Trim());

                txtBarcode.Clear();
                txtBarcode.Focus();

                e.SuppressKeyPress = true;
            }
        }

        private void AddProductToCart(string barcode)
        {
            if (string.IsNullOrWhiteSpace(barcode))
                return;

            try
            {
                DatabaseHelper db = new DatabaseHelper();

                var result = db.ExecuteQuery(
                    "sp_GetProductByBarcode",
                    new SqlParameter("@Barcode", barcode)
                );

                if (result.Rows.Count == 0)
                {
                    System.Media.SystemSounds.Beep.Play();
                    return;
                }

                var row = result.Rows[0];

                int productId = Convert.ToInt32(row["ProductId"]);
                string name = row["ProductName"].ToString();
                decimal price = Convert.ToDecimal(row["SellingPrice"]);
                int stock = Convert.ToInt32(row["StockQuantity"]);

                // Check if already in cart
                var existing = cart.FirstOrDefault(p => p.ProductId == productId);

                if (existing != null)
                {
                    // Stock validation
                    if (existing.Quantity + 1 > stock)
                    {
                        System.Media.SystemSounds.Beep.Play();
                        return;
                    }

                    existing.Quantity++;
                }
                else
                {
                    // Out of stock
                    if (stock <= 0)
                    {
                        System.Media.SystemSounds.Beep.Play();
                        return;
                    }

                    cart.Add(new CartItem
                    {
                        ProductId = productId,
                        ProductName = name,
                        Price = price,
                        Quantity = 1
                    });
                }

                RefreshCart();
                UpdateTotal();

            }
            catch (Exception ex)
            {
                MessageBox.Show("Error adding product: " + ex.Message);
            }
        }

        // CART LOGIC
        private void dgvCart_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            // Ignore header clicks
            if (e.RowIndex < 0)
                return;

            // Check if it's the button column (last column)
            if (dgvCart.Columns[e.ColumnIndex] is DataGridViewButtonColumn)
            {
                var item = dgvCart.Rows[e.RowIndex].DataBoundItem as CartItem;

                if (item != null)
                {
                    cart.Remove(item);
                }
            }
        }

        private void dgvCart_KeyDown(object sender, KeyEventArgs e)
        {
            // Deletes an entire row using keyboard
            if (e.KeyCode == Keys.Delete && dgvCart.CurrentRow != null)
            {
                var item = dgvCart.CurrentRow.DataBoundItem as CartItem;
                if (item != null)
                {
                    cart.Remove(item);
                    RefreshCart();
                    UpdateTotal();
                }
            }
        }

        private void dgvCart_CellBeginEdit(object sender, DataGridViewCellCancelEventArgs e)
        {
            if (dgvCart.Columns[e.ColumnIndex].DataPropertyName == "Quantity")
            {
                var item = cart[e.RowIndex];
                oldQuantity = item.Quantity;
            }
        }

        private void dgvCart_CellEndEdit(object sender, DataGridViewCellEventArgs e)
        {
            if (dgvCart.Columns[e.ColumnIndex].DataPropertyName == "Quantity")
            {
                var item = cart[e.RowIndex];

                var cellValue = dgvCart.Rows[e.RowIndex].Cells[e.ColumnIndex].Value?.ToString();

                if (!int.TryParse(cellValue, out int value) || value < 0)
                {
                    item.Quantity = oldQuantity;
                    return;
                }

                item.Quantity = value;

                if (item.Quantity == 0)
                {
                    cart.Remove(item);
                }
            }

            RefreshCart();
            UpdateTotal();
        }

        private void SetupCartGrid()
        {
            dgvCart.AutoGenerateColumns = false;
            dgvCart.DataSource = cart;

            dgvCart.Columns.Clear();

            // Product name
            dgvCart.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "ProductName",
                DataPropertyName = "ProductName",
                HeaderText = "Product",
                Width = 250
            });
            dgvCart.Columns["ProductName"].ReadOnly = true;

            // Single unit price
            dgvCart.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "Price",
                DataPropertyName = "Price",
                HeaderText = "Price",
                Width = 100,
                DefaultCellStyle = new DataGridViewCellStyle { Format = "N0" }
            });
            dgvCart.Columns["Price"].ReadOnly = true;

            // Quantity of products
            dgvCart.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "Quantity",
                DataPropertyName = "Quantity",
                HeaderText = "Qty",
                Width = 80
            });

            // Total price of product group
            dgvCart.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "Total",
                DataPropertyName = "Total",
                HeaderText = "Total",
                Width = 120,
                DefaultCellStyle = new DataGridViewCellStyle { Format = "N0" }
            });
            dgvCart.Columns["Total"].ReadOnly = true;

            // Remove-product-group-from-list button
            dgvCart.Columns.Add(new DataGridViewButtonColumn
            {
                Name = "btnDeleteRow",
                HeaderText = "",
                Text = "X",
                UseColumnTextForButtonValue = true,
                Width = 40
            });

            dgvCart.AllowUserToAddRows = false;
            dgvCart.RowHeadersVisible = false;
        }

        // CHECKOUT LOGIC
        private int ProcessCheckout()
        {
            try
            {
                DatabaseHelper db = new DatabaseHelper();

                var saleResult = db.ExecuteQuery(
                    "sp_CreateSale",
                    new SqlParameter("@EmployeeId", UserSession.EmployeeId),
                    new SqlParameter("@CustomerId", DBNull.Value),
                    new SqlParameter("@CustomerName", DBNull.Value),
                    new SqlParameter("@CustomerPhone", DBNull.Value),
                    new SqlParameter("@PaymentMethod", "Cash")
                );

                int saleId = Convert.ToInt32(saleResult.Rows[0]["SaleId"]);

                foreach (var item in cart)
                {
                    db.ExecuteNonQuery(
                        "sp_AddSaleDetail",
                        new SqlParameter("@SaleId", saleId),
                        new SqlParameter("@ProductId", item.ProductId),
                        new SqlParameter("@Quantity", item.Quantity)
                    );
                }

                db.ExecuteNonQuery(
                    "sp_FinalizeSale",
                    new SqlParameter("@SaleId", saleId),
                    new SqlParameter("@Discount", 0)
                );

                cart.Clear();

                return saleId;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Checkout failed: " + ex.Message);
                return -1;
            }
        }

        // UI INTERACTIONS
        private void btnAddToCart_Click(object sender, EventArgs e)
        {
            AddProductToCart(txtBarcode.Text.Trim());
            txtBarcode.Clear();
            txtBarcode.Focus();
        }

        private void btnCheckout_Click(object sender, EventArgs e)
        {
            if (cart.Count == 0)
            {
                MessageBox.Show("Giỏ hàng trống.");
                return;
            }

            decimal total = cart.Sum(x => x.Total);

            using (var frmCheckout = new FrmCheckout(cart.ToList(), total))
            {
                if (frmCheckout.ShowDialog() == DialogResult.OK)
                {
                    int saleId = ProcessCheckout();

                    if (saleId > 0)
                    {
                        var frmInvoice = new FrmInvoice(saleId);
                        frmInvoice.ShowDialog();
                    }
                }
            }
        }

        private void btnClearCart_Click(object sender, EventArgs e)
        {
            cart.Clear();
            RefreshCart();
        }
    }
}

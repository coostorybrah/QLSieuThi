namespace QLSieuThi
{
    partial class FrmCheckout
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.cartHeading = new System.Windows.Forms.Label();
            this.lblTotalText = new System.Windows.Forms.Label();
            this.lblTotalValue = new System.Windows.Forms.Label();
            this.lblAmountPaid = new System.Windows.Forms.Label();
            this.lblChangeText = new System.Windows.Forms.Label();
            this.lblChangeValue = new System.Windows.Forms.Label();
            this.btnConfirm = new System.Windows.Forms.Button();
            this.btnCancel = new System.Windows.Forms.Button();
            this.txtAmountPaid = new System.Windows.Forms.TextBox();
            this.lstSummary = new System.Windows.Forms.ListBox();
            this.SuspendLayout();
            // 
            // cartHeading
            // 
            this.cartHeading.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.cartHeading.AutoSize = true;
            this.cartHeading.Font = new System.Drawing.Font("Microsoft Sans Serif", 16.2F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(163)));
            this.cartHeading.Location = new System.Drawing.Point(256, 9);
            this.cartHeading.Name = "cartHeading";
            this.cartHeading.Size = new System.Drawing.Size(205, 32);
            this.cartHeading.TabIndex = 2;
            this.cartHeading.Text = "THANH TOÁN";
            // 
            // lblTotalText
            // 
            this.lblTotalText.AutoSize = true;
            this.lblTotalText.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(163)));
            this.lblTotalText.Location = new System.Drawing.Point(110, 297);
            this.lblTotalText.Name = "lblTotalText";
            this.lblTotalText.Size = new System.Drawing.Size(100, 25);
            this.lblTotalText.TabIndex = 3;
            this.lblTotalText.Text = "Tổng tiền:";
            // 
            // lblTotalValue
            // 
            this.lblTotalValue.AutoSize = true;
            this.lblTotalValue.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(163)));
            this.lblTotalValue.Location = new System.Drawing.Point(240, 297);
            this.lblTotalValue.Name = "lblTotalValue";
            this.lblTotalValue.Size = new System.Drawing.Size(23, 25);
            this.lblTotalValue.TabIndex = 4;
            this.lblTotalValue.Text = "0";
            // 
            // lblAmountPaid
            // 
            this.lblAmountPaid.AutoSize = true;
            this.lblAmountPaid.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(163)));
            this.lblAmountPaid.Location = new System.Drawing.Point(110, 380);
            this.lblAmountPaid.Name = "lblAmountPaid";
            this.lblAmountPaid.Size = new System.Drawing.Size(113, 25);
            this.lblAmountPaid.TabIndex = 5;
            this.lblAmountPaid.Text = "Khách đưa:";
            // 
            // lblChangeText
            // 
            this.lblChangeText.AutoSize = true;
            this.lblChangeText.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(163)));
            this.lblChangeText.Location = new System.Drawing.Point(110, 476);
            this.lblChangeText.Name = "lblChangeText";
            this.lblChangeText.Size = new System.Drawing.Size(100, 25);
            this.lblChangeText.TabIndex = 7;
            this.lblChangeText.Text = "Tiền thừa:";
            // 
            // lblChangeValue
            // 
            this.lblChangeValue.AutoSize = true;
            this.lblChangeValue.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(163)));
            this.lblChangeValue.Location = new System.Drawing.Point(240, 476);
            this.lblChangeValue.Name = "lblChangeValue";
            this.lblChangeValue.Size = new System.Drawing.Size(23, 25);
            this.lblChangeValue.TabIndex = 8;
            this.lblChangeValue.Text = "0";
            // 
            // btnConfirm
            // 
            this.btnConfirm.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(163)));
            this.btnConfirm.Location = new System.Drawing.Point(115, 529);
            this.btnConfirm.Name = "btnConfirm";
            this.btnConfirm.Size = new System.Drawing.Size(181, 42);
            this.btnConfirm.TabIndex = 9;
            this.btnConfirm.Text = "XÁC NHẬN";
            this.btnConfirm.UseVisualStyleBackColor = true;
            this.btnConfirm.Click += new System.EventHandler(this.btnConfirm_Click);
            // 
            // btnCancel
            // 
            this.btnCancel.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(163)));
            this.btnCancel.Location = new System.Drawing.Point(428, 529);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(181, 42);
            this.btnCancel.TabIndex = 10;
            this.btnCancel.Text = "HỦY";
            this.btnCancel.UseVisualStyleBackColor = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // txtAmountPaid
            // 
            this.txtAmountPaid.Location = new System.Drawing.Point(115, 418);
            this.txtAmountPaid.Name = "txtAmountPaid";
            this.txtAmountPaid.Size = new System.Drawing.Size(232, 22);
            this.txtAmountPaid.TabIndex = 11;
            this.txtAmountPaid.TextChanged += new System.EventHandler(this.txtAmountPaid_TextChanged);
            // 
            // lstSummary
            // 
            this.lstSummary.FormattingEnabled = true;
            this.lstSummary.ItemHeight = 16;
            this.lstSummary.Location = new System.Drawing.Point(115, 76);
            this.lstSummary.Name = "lstSummary";
            this.lstSummary.Size = new System.Drawing.Size(534, 180);
            this.lstSummary.TabIndex = 12;
            // 
            // FrmCheckout
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(745, 625);
            this.ControlBox = false;
            this.Controls.Add(this.lstSummary);
            this.Controls.Add(this.txtAmountPaid);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnConfirm);
            this.Controls.Add(this.lblChangeValue);
            this.Controls.Add(this.lblChangeText);
            this.Controls.Add(this.lblAmountPaid);
            this.Controls.Add(this.lblTotalValue);
            this.Controls.Add(this.lblTotalText);
            this.Controls.Add(this.cartHeading);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Name = "FrmCheckout";
            this.Text = "Thanh toán";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label cartHeading;
        private System.Windows.Forms.Label lblTotalText;
        private System.Windows.Forms.Label lblTotalValue;
        private System.Windows.Forms.Label lblAmountPaid;
        private System.Windows.Forms.Label lblChangeText;
        private System.Windows.Forms.Label lblChangeValue;
        private System.Windows.Forms.Button btnConfirm;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.TextBox txtAmountPaid;
        private System.Windows.Forms.ListBox lstSummary;
    }
}
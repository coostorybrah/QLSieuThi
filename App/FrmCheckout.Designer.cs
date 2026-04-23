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
            this.cartHeading.Font = new System.Drawing.Font("Arial", 16.2F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(163)));
            this.cartHeading.Location = new System.Drawing.Point(198, 15);
            this.cartHeading.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.cartHeading.Name = "cartHeading";
            this.cartHeading.Size = new System.Drawing.Size(160, 26);
            this.cartHeading.TabIndex = 2;
            this.cartHeading.Text = "THANH TOÁN";
            // 
            // lblTotalText
            // 
            this.lblTotalText.AutoSize = true;
            this.lblTotalText.Font = new System.Drawing.Font("Arial", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(163)));
            this.lblTotalText.Location = new System.Drawing.Point(84, 226);
            this.lblTotalText.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.lblTotalText.Name = "lblTotalText";
            this.lblTotalText.Size = new System.Drawing.Size(87, 19);
            this.lblTotalText.TabIndex = 3;
            this.lblTotalText.Text = "Tổng tiền:";
            // 
            // lblTotalValue
            // 
            this.lblTotalValue.AutoSize = true;
            this.lblTotalValue.Font = new System.Drawing.Font("Arial", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(163)));
            this.lblTotalValue.Location = new System.Drawing.Point(175, 226);
            this.lblTotalValue.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.lblTotalValue.Name = "lblTotalValue";
            this.lblTotalValue.Size = new System.Drawing.Size(18, 19);
            this.lblTotalValue.TabIndex = 4;
            this.lblTotalValue.Text = "0";
            // 
            // lblAmountPaid
            // 
            this.lblAmountPaid.AutoSize = true;
            this.lblAmountPaid.Font = new System.Drawing.Font("Arial", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(163)));
            this.lblAmountPaid.Location = new System.Drawing.Point(83, 280);
            this.lblAmountPaid.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.lblAmountPaid.Name = "lblAmountPaid";
            this.lblAmountPaid.Size = new System.Drawing.Size(100, 19);
            this.lblAmountPaid.TabIndex = 5;
            this.lblAmountPaid.Text = "Khách đưa:";
            // 
            // lblChangeText
            // 
            this.lblChangeText.AutoSize = true;
            this.lblChangeText.Font = new System.Drawing.Font("Arial", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(163)));
            this.lblChangeText.Location = new System.Drawing.Point(83, 330);
            this.lblChangeText.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.lblChangeText.Name = "lblChangeText";
            this.lblChangeText.Size = new System.Drawing.Size(88, 19);
            this.lblChangeText.TabIndex = 7;
            this.lblChangeText.Text = "Tiền thừa:";
            // 
            // lblChangeValue
            // 
            this.lblChangeValue.AutoSize = true;
            this.lblChangeValue.Font = new System.Drawing.Font("Arial", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(163)));
            this.lblChangeValue.Location = new System.Drawing.Point(175, 330);
            this.lblChangeValue.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.lblChangeValue.Name = "lblChangeValue";
            this.lblChangeValue.Size = new System.Drawing.Size(18, 19);
            this.lblChangeValue.TabIndex = 8;
            this.lblChangeValue.Text = "0";
            // 
            // btnConfirm
            // 
            this.btnConfirm.Font = new System.Drawing.Font("Arial", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(163)));
            this.btnConfirm.Location = new System.Drawing.Point(118, 393);
            this.btnConfirm.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.btnConfirm.Name = "btnConfirm";
            this.btnConfirm.Size = new System.Drawing.Size(142, 34);
            this.btnConfirm.TabIndex = 9;
            this.btnConfirm.Text = "XÁC NHẬN";
            this.btnConfirm.UseVisualStyleBackColor = true;
            this.btnConfirm.Click += new System.EventHandler(this.btnConfirm_Click);
            // 
            // btnCancel
            // 
            this.btnCancel.Font = new System.Drawing.Font("Arial", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(163)));
            this.btnCancel.Location = new System.Drawing.Point(315, 393);
            this.btnCancel.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(133, 34);
            this.btnCancel.TabIndex = 10;
            this.btnCancel.Text = "HỦY";
            this.btnCancel.UseVisualStyleBackColor = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // txtAmountPaid
            // 
            this.txtAmountPaid.Font = new System.Drawing.Font("Arial", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(163)));
            this.txtAmountPaid.Location = new System.Drawing.Point(187, 280);
            this.txtAmountPaid.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.txtAmountPaid.Name = "txtAmountPaid";
            this.txtAmountPaid.Size = new System.Drawing.Size(212, 26);
            this.txtAmountPaid.TabIndex = 11;
            this.txtAmountPaid.TextChanged += new System.EventHandler(this.txtAmountPaid_TextChanged);
            // 
            // lstSummary
            // 
            this.lstSummary.Font = new System.Drawing.Font("Arial", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(163)));
            this.lstSummary.FormattingEnabled = true;
            this.lstSummary.ItemHeight = 18;
            this.lstSummary.Location = new System.Drawing.Point(86, 62);
            this.lstSummary.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.lstSummary.Name = "lstSummary";
            this.lstSummary.Size = new System.Drawing.Size(402, 130);
            this.lstSummary.TabIndex = 12;
            // 
            // FrmCheckout
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(559, 508);
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
            this.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
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
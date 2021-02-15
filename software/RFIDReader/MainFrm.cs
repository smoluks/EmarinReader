using BitStreams;
using RFIDReader.Entity;
using RFIDReader.Managers;
using System;
using System.Drawing;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters.Binary;
using System.Threading;
using System.Windows.Forms;

namespace RFIDReader
{
    public partial class MainFrm : Form
    {
        CommandManager _commandManager;
        private Emarin _emarinKey;
        CancellationTokenSource _formCancellationTokenSource;
        CancellationToken _formCancellationToken;

        public MainFrm()
        {
            InitializeComponent();
        }

        private void MainFrm_Load(object sender, System.EventArgs e)
        {
            _formCancellationTokenSource = new CancellationTokenSource();
            _formCancellationToken = _formCancellationTokenSource.Token;

            RefreshComPorts();
        }

        private void MainFrm_FormClosed(object sender, FormClosedEventArgs e)
        {
            _formCancellationTokenSource.Cancel();

            _commandManager?.Dispose();
        }

        private void btnRefresh_Click(object sender, System.EventArgs e)
        {
            RefreshComPorts();
        }

        private void RefreshComPorts()
        {
            cbComPort.Items.Clear();

            foreach (var port in ComPortManager.GetAvaliableComPorts())
            {
                cbComPort.Items.Add(port);
            }

            if (cbComPort.Items.Count > 0)
                cbComPort.SelectedIndex = cbComPort.Items.Count - 1;
        }

        private async void btnConnect_Click(object sender, EventArgs e)
        {
            lblStatus.Text = $"Connecting to {(string)cbComPort.SelectedItem}...";

            try
            {
                _commandManager = new CommandManager((string)cbComPort.SelectedItem);

                await _commandManager.PingAsync(CancellationToken.None);

                tabControl1.Enabled = true;
                btnDisconnect.Enabled = true;

                btnConnect.Enabled = false;
                lblStatus.Text = $"Connected to {(string)cbComPort.SelectedItem}";
            }
            catch (Exception ex)
            {
                lblStatus.Text = $"Connecting to {(string)cbComPort.SelectedItem} failed: {ex.Message}";
            }            
        }

        private void btnDisconnect_Click(object sender, EventArgs e)
        {
            _commandManager?.Dispose();
            tabControl1.Enabled = false;
            btnDisconnect.Enabled = false;

            btnConnect.Enabled = true;

            lblStatus.Text = $"Disconnected";
        }

        private async void btnRead_ClickAsync(object sender, EventArgs e)
        {
            lblStatus.Text = $"Reading Emarin...";

            try
            {
                _emarinKey = await _commandManager.ReadEmarinAsync(_formCancellationToken);

                tbH1.Invoke(new Action(
                    () =>
                    {
                        ShowEmarin(_emarinKey);
                    }));

                lblStatus.Text = $"Read Emarin done";
                btnValidate.Enabled = true;
            }
            catch (Exception ex)
            {
                lblStatus.Text = $"Read Emarin error: {ex.Message}";
            }
        }

        private async void btnValidate_ClickAsync(object sender, EventArgs e)
        {
            lblStatus.Text = $"Validating Emarin...";

            try
            {
                var key = await _commandManager.ReadEmarinAsync(_formCancellationToken);

                if (_emarinKey.CompareTo(key))
                {
                    lblStatus.Text = $"Validation OK";
                }
                else
                {
                    lblStatus.Text = $"Validation failed";
                }
            }
            catch (Exception ex)
            {
                lblStatus.Text = $"Validating Emarin error: {ex.Message}";
            }
        }


        private async void btnWrite4305_ClickAsync(object sender, EventArgs e)
        {
            lblStatus.Text = $"Writing EM4305...";

            try
            {
                await _commandManager.Login4305Async(_formCancellationToken);

                await _commandManager.Write4305Async(4, new byte[] { 0x5F, 0x80, 0x01, 0x00 }, _formCancellationToken);

                var raw = _emarinKey.ToByteArray();

                await _commandManager.Write4305Async(5, new byte[] { raw[0], raw[1], raw[2], raw[3] }, _formCancellationToken);
                await _commandManager.Write4305Async(6, new byte[] { raw[4], raw[5], raw[6], raw[7] }, _formCancellationToken);

                var key = await _commandManager.ReadEmarinAsync(_formCancellationToken);

                if (_emarinKey.CompareTo(key))
                {
                    lblStatus.Text = $"Validation OK";
                }
                else
                {
                    lblStatus.Text = $"Validation failed";
                }
            }
            catch (Exception ex)
            {
                lblStatus.Text = $"Writing EM4305 error: {ex.Message}";
            }
        }

        private void btnOpenEmarin_Click(object sender, EventArgs e)
        {
            if (openFileDialog1.ShowDialog() == DialogResult.OK)
            {
                IFormatter formatter = new BinaryFormatter();
                Stream stream = new FileStream(openFileDialog1.FileName, FileMode.Open, FileAccess.Read, FileShare.Read);
                _emarinKey = (Emarin)formatter.Deserialize(stream);
                stream.Close();

                ShowEmarin(_emarinKey);
                btnValidate.Enabled = true;
            }
        }

        private void btnSaveEmarin_Click(object sender, EventArgs e)
        {
            if (saveFileDialog1.ShowDialog() == DialogResult.OK)
            {
                IFormatter formatter = new BinaryFormatter();
                var stream = new FileStream(saveFileDialog1.FileName, FileMode.Create, FileAccess.Write, FileShare.None);
                formatter.Serialize(stream, _emarinKey);
                stream.Close();
            }
        }

        void ShowEmarin(Emarin key)
        {
            tbH1.Text = BitToText(key.Header[0]);
            if (!key.Header[0]) tbH1.BackColor = Color.Red;
            tbH2.Text = BitToText(key.Header[1]);
            if (!key.Header[1]) tbH2.BackColor = Color.Red;
            tbH3.Text = BitToText(key.Header[2]);
            if (!key.Header[2]) tbH3.BackColor = Color.Red;
            tbH4.Text = BitToText(key.Header[3]);
            if (!key.Header[3]) tbH4.BackColor = Color.Red;
            tbH5.Text = BitToText(key.Header[4]);
            if (!key.Header[4]) tbH5.BackColor = Color.Red;
            tbH6.Text = BitToText(key.Header[5]);
            if (!key.Header[5]) tbH6.BackColor = Color.Red;
            tbH7.Text = BitToText(key.Header[6]);
            if (!key.Header[6]) tbH7.BackColor = Color.Red;
            tbH8.Text = BitToText(key.Header[7]);
            if (!key.Header[7]) tbH8.BackColor = Color.Red;
            tbH9.Text = BitToText(key.Header[8]);
            if (!key.Header[8]) tbH9.BackColor = Color.Red;

            tbR1.Text = BitToText(key.RowParity[0]);
            if (key.RowParity[0] ^ key.GetRowParity(0)) tbR1.BackColor = Color.Red;
            tbR2.Text = BitToText(key.RowParity[1]);
            if (key.RowParity[1] ^ key.GetRowParity(1)) tbR2.BackColor = Color.Red;
            tbR3.Text = BitToText(key.RowParity[2]);
            if (key.RowParity[2] ^ key.GetRowParity(2)) tbR3.BackColor = Color.Red;
            tbR4.Text = BitToText(key.RowParity[3]);
            if (key.RowParity[3] ^ key.GetRowParity(3)) tbR4.BackColor = Color.Red;
            tbR5.Text = BitToText(key.RowParity[4]);
            if (key.RowParity[4] ^ key.GetRowParity(4)) tbR5.BackColor = Color.Red;
            tbR6.Text = BitToText(key.RowParity[5]);
            if (key.RowParity[5] ^ key.GetRowParity(5)) tbR6.BackColor = Color.Red;
            tbR7.Text = BitToText(key.RowParity[6]);
            if (key.RowParity[6] ^ key.GetRowParity(6)) tbR7.BackColor = Color.Red;
            tbR8.Text = BitToText(key.RowParity[7]);
            if (key.RowParity[7] ^ key.GetRowParity(7)) tbR8.BackColor = Color.Red;
            tbR9.Text = BitToText(key.RowParity[8]);
            if (key.RowParity[8] ^ key.GetRowParity(8)) tbR9.BackColor = Color.Red;
            tbR0.Text = BitToText(key.RowParity[9]);
            if (key.RowParity[9] ^ key.GetRowParity(9)) tbR0.BackColor = Color.Red;

            tbD11.Text = BitToText(key.Data[0, 0]);
            tbD12.Text = BitToText(key.Data[0, 1]);
            tbD13.Text = BitToText(key.Data[0, 2]);
            tbD14.Text = BitToText(key.Data[0, 3]);

            tbD21.Text = BitToText(key.Data[1, 0]);
            tbD22.Text = BitToText(key.Data[1, 1]);
            tbD23.Text = BitToText(key.Data[1, 2]);
            tbD24.Text = BitToText(key.Data[1, 3]);

            tbD31.Text = BitToText(key.Data[2, 0]);
            tbD32.Text = BitToText(key.Data[2, 1]);
            tbD33.Text = BitToText(key.Data[2, 2]);
            tbD34.Text = BitToText(key.Data[2, 3]);

            tbD41.Text = BitToText(key.Data[3, 0]);
            tbD42.Text = BitToText(key.Data[3, 1]);
            tbD43.Text = BitToText(key.Data[3, 2]);
            tbD44.Text = BitToText(key.Data[3, 3]);

            tbD51.Text = BitToText(key.Data[4, 0]);
            tbD52.Text = BitToText(key.Data[4, 1]);
            tbD53.Text = BitToText(key.Data[4, 2]);
            tbD54.Text = BitToText(key.Data[4, 3]);

            tbD61.Text = BitToText(key.Data[5, 0]);
            tbD62.Text = BitToText(key.Data[5, 1]);
            tbD63.Text = BitToText(key.Data[5, 2]);
            tbD64.Text = BitToText(key.Data[5, 3]);

            tbD71.Text = BitToText(key.Data[6, 0]);
            tbD72.Text = BitToText(key.Data[6, 1]);
            tbD73.Text = BitToText(key.Data[6, 2]);
            tbD74.Text = BitToText(key.Data[6, 3]);

            tbD81.Text = BitToText(key.Data[7, 0]);
            tbD82.Text = BitToText(key.Data[7, 1]);
            tbD83.Text = BitToText(key.Data[7, 2]);
            tbD84.Text = BitToText(key.Data[7, 3]);

            tbD91.Text = BitToText(key.Data[8, 0]);
            tbD92.Text = BitToText(key.Data[8, 1]);
            tbD93.Text = BitToText(key.Data[8, 2]);
            tbD94.Text = BitToText(key.Data[8, 3]);

            tbD01.Text = BitToText(key.Data[9, 0]);
            tbD02.Text = BitToText(key.Data[9, 1]);
            tbD03.Text = BitToText(key.Data[9, 2]);
            tbD04.Text = BitToText(key.Data[9, 3]);

            tbC1.Text = BitToText(key.ColumnParity[0]);
            if (key.ColumnParity[0] ^ key.GetColumnParity(0)) tbC1.BackColor = Color.Red;
            tbC2.Text = BitToText(key.ColumnParity[1]);
            if (key.ColumnParity[1] ^ key.GetColumnParity(1)) tbC2.BackColor = Color.Red;
            tbC3.Text = BitToText(key.ColumnParity[2]);
            if (key.ColumnParity[2] ^ key.GetColumnParity(2)) tbC3.BackColor = Color.Red;
            tbC4.Text = BitToText(key.ColumnParity[3]);
            if (key.ColumnParity[3] ^ key.GetColumnParity(3)) tbC4.BackColor = Color.Red;

            tbP1.Text = BitToText(key.StopBit);
            if (key.StopBit) tbP1.BackColor = Color.Red;
        }

        private string BitToText(Bit bit)
        {
            return bit ? "1" : "0";
        }
    }
}

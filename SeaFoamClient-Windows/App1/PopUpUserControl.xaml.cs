using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Navigation;

using Windows.Storage.Streams;
using Windows.Networking;
using Windows.Networking.Sockets;
// The User Control item template is documented at http://go.microsoft.com/fwlink/?LinkId=234236

namespace App1
{
    public sealed partial class PopUpUserControl : UserControl
    {
        public static StreamSocket mySocket = new StreamSocket();

        public PopUpUserControl()
        {
            this.InitializeComponent();
        }

        private void btnCancel_Click(object sender, RoutedEventArgs e)
        {
            // in this example we assume the parent of the UserControl is a Popup 
            Popup p = this.Parent as Popup;

            // close the Popup
            if (p != null) { p.IsOpen = false; }  
        }

        private async void RegisterUser()
        {
            DataWriter dw = new DataWriter(mySocket.OutputStream);
            // send login info to socket
            //{action:CREATE_ACCOUNT, args:username|password}
            dw.WriteString("{action:CREATE_ACCOUNT, args:" + tbx1.Text + "|" + pbx1.Password); //Tid|tid
            await dw.StoreAsync();
        }

        private void btnOK_Click(object sender, RoutedEventArgs e)
        {

            // in this example we assume the parent of the UserControl is a Popup 
            Popup p = this.Parent as Popup;

            RegisterUser();
            // close the Popup
            if (p != null) { p.IsOpen = false; }  
    
        }
    }
}

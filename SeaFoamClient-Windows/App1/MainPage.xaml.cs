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
using System.Text;
using Windows.UI.Popups;

// The Blank Page item template is documented at http://go.microsoft.com/fwlink/?LinkId=234238

namespace App1
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class MainPage : Page
    {

        public MainPage()
        {
            this.InitializeComponent();
        }

        private void login_Click(object sender, RoutedEventArgs e)
        {
            check_login();
        }

        private async void authenticateUser()
        {
            var streamScoket = new StreamSocket();
            await streamScoket.ConnectAsync(new HostName("50.63.60.10"), "534", SocketProtectionLevel.PlainSocket);
            DataWriter dw = new DataWriter(streamScoket.OutputStream);
            dw.WriteString("{action:LOGIN, args:"+usernameInput.Text+"|"+passwordInput.Password+", sessionId:}"); //Tid|tid
            await dw.StoreAsync();

            DataReader reader = new DataReader(streamScoket.InputStream);
            reader.InputStreamOptions = InputStreamOptions.Partial;
            await reader.LoadAsync(1024);
            string data = string.Empty;
            while (reader.UnconsumedBufferLength > 0)
            {
                data += reader.ReadString(reader.UnconsumedBufferLength);
            }

            tempBox.Text =data;

        }
            
        private async void check_login()
        {
            if (String.IsNullOrEmpty(usernameInput.Text))
            {
                Windows.UI.Popups.MessageDialog messageDialog =
                    new Windows.UI.Popups.MessageDialog("You must enter a username");
                await messageDialog.ShowAsync();
            }
            else if (String.IsNullOrEmpty(passwordInput.Password))
            {
                Windows.UI.Popups.MessageDialog messageDialog =
                    new Windows.UI.Popups.MessageDialog("You must enter a password");
                await messageDialog.ShowAsync();
            }
            else 
            { 
                /* replace with server side code */
                // trim whitespace ? //
                authenticateUser();
                if( true  )
                {
                    

                    Windows.UI.Popups.MessageDialog messageDialog =
                        new Windows.UI.Popups.MessageDialog("login succcessful, welcome "+usernameInput.Text);
                    await messageDialog.ShowAsync();
                    this.Frame.Navigate(typeof(BlankPage1));
                }
                else
                {
                    Windows.UI.Popups.MessageDialog messageDialog =
                        new Windows.UI.Popups.MessageDialog("Invalid username/password");
                    await messageDialog.ShowAsync();
                    usernameInput.Text = "";
                    passwordInput.Password = "";
                }
            }
        }

        private void NewUserButton_Click(object sender, RoutedEventArgs e)
        {
            Popup popup = new Popup();
            popup.Height = 300;
            popup.Width = 400;
            popup.VerticalOffset = 100;
            PopUpUserControl control = new PopUpUserControl();
            popup.Child = control;
            popup.IsOpen = true;



        }
    }
}

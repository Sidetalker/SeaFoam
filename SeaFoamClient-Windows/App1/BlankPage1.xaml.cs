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

using Newtonsoft.Json;


// The Blank Page item template is documented at http://go.microsoft.com/fwlink/?LinkId=234238

namespace App1
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class BlankPage1 : Page
    {
        public static StreamSocket mySocket = new StreamSocket();
        public string myUserID;

        public BlankPage1(StreamSocket sockt, string userID)
        {
            mySocket = sockt;
            myUserID = userID;
            this.InitializeComponent();
        }


        private async void testChatrooms()
        {
                // {action:LIST_CHATS, args:, userID:1234}
                DataWriter dw = new DataWriter(mySocket.OutputStream);
                // send login info to socket
                dw.WriteString("{action:LIST_CHATS, args:, userID:"+myUserID+"}"); //Tid|tid
                await dw.StoreAsync();
                

                DataReader reader = new DataReader(mySocket.InputStream);
                reader.InputStreamOptions = InputStreamOptions.Partial;
                await reader.LoadAsync(1024);
                string data = string.Empty;

                while (reader.UnconsumedBufferLength > 0)
                {
                    data += reader.ReadString(reader.UnconsumedBufferLength);
                    MessageDisplay.Text += data;
                }
                //MessageDisplay.Text = data;

        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            testChatrooms();

        }
    }
}

<#
.SYNOPSIS
  Tiny TCP forwarder. Bridges 0.0.0.0:LISTEN -> 127.0.0.1:TARGET.

.DESCRIPTION
  Used to expose Edge's CDP endpoint (which only binds to 127.0.0.1 due to
  Chromium's DNS-rebinding mitigation) to WSL clients.

  Compiles a tiny C# class via Add-Type for clean async I/O via .NET's TPL.
  Runs in a single process; per-connection work happens on the .NET thread
  pool, not via per-connection runspaces. No external dependencies.

.PARAMETER ListenPort
  Local TCP port to listen on. Default 9223.

.PARAMETER TargetPort
  Local TCP port to forward to. Default 9222.
#>
param(
  [int]$ListenPort = 9223,
  [int]$TargetPort = 9222
)

$ErrorActionPreference = 'Stop'

Add-Type -Language CSharp -TypeDefinition @'
using System;
using System.Net;
using System.Net.Sockets;
using System.Threading.Tasks;

public static class CdpForwarder {
  public static async Task RunAsync(int listenPort, int targetPort) {
    var listener = new TcpListener(IPAddress.Any, listenPort);
    listener.Start();
    Console.Error.WriteLine("Forwarding 0.0.0.0:" + listenPort + " -> 127.0.0.1:" + targetPort);
    while (true) {
      var client = await listener.AcceptTcpClientAsync();
      // Fire-and-forget. Each handler manages its own lifetime via `using`.
      var _ignored = HandleAsync(client, targetPort);
    }
  }

  static async Task HandleAsync(TcpClient client, int targetPort) {
    try {
      using (client) {
        using (var upstream = new TcpClient()) {
          await upstream.ConnectAsync(IPAddress.Loopback, targetPort);
          using (var cs = client.GetStream())
          using (var us = upstream.GetStream()) {
            // Bidirectional pump. WhenAny: as soon as either side closes,
            // tear the pair down so the other CopyToAsync unblocks.
            var a = cs.CopyToAsync(us);
            var b = us.CopyToAsync(cs);
            await Task.WhenAny(a, b);
          }
        }
      }
    } catch {
      // Connection-level errors are routine (peer reset, abort, etc.).
      // Swallow per-connection failures; the listener keeps running.
    }
  }
}
'@

[CdpForwarder]::RunAsync($ListenPort, $TargetPort).GetAwaiter().GetResult()

TacoSpigot ![Cancer Warning](https://img.shields.io/badge/1.8.8-causes%20cancer-red) ![Maintenance](https://img.shields.io/maintenance/no/2018)
===============================

A *unsupported* and unmaintained fork of [PaperMC](https://papermc.io/).

- Modern versions - Switch to [PaperMC](https://papermc.io)
- 1.8.8 - Do not use 1.8.8. See below for warnings, security vulnerabilities, and backwards-compatibility layers (ProtocolSupport/ViaVersion).

Rest in peace my dear tacos :)

## Alternatives
If you are using modern minecraft, please use [PaperMC](https://papermc.io/).

It is stable, highly performant, modern and well run. It already contains most of the TacoSpigot patches.

This repository exists for historical interest only.

I am currently in semi-retirement from Minecraft work. If I ever do continue working on the server server, I intend to contribute directly to Paper instead of running a fork.

### Using 1.8.8
If you are using 1.8.8 please discontinue using it *immediately*.

There are multiple confirmed security exploits that will allow **item duplication** and even **server takeover**.

These security vulnerabilites will not be patched, and most "TacoSpigot forks" do not actually fix these vulnerabilites. They often make them worse.

Due to the excellent work of the [PaperMC](https://papermc.io) team, most of the performance problems in modern minecraft (1.17) have been fixed.

At this point, performance of Paper 1.16 & 1.17 should be *better* than TacoSpigot 1.8.8 (or any of the billion forks).

For those concerned with PVP, there are several ways to emulate the old behavior on a modern server. These include config options, plugins and server forks.

In addition you can run a compatibility layer (see below) to allow clients to keep connecting with their old .

#### Compatibility Layers
For those of you still interested in supporting 1.8.8 *clients* connecting to to a modern (1.16/1.17) servers, there are several compatibility layers.

1. [ProtocolSupport](https://protocol.support/) directly supports 1.8.8 clients. Just install that plugin and your old clients should be able to connect to your new server!
2. You can use a combination of [ViaVersion](viaversion.com) along with [ViaRewind](https://www.spigotmc.org/resources/viarewind.52109/) and [ViaBackwards](https://www.spigotmc.org/resources/viabackwards.27448/).
  - ViaVersion alone is not sufficent to support 1.8 clients on a modern server. You need all three plugins

I highly recomend using one of these two compatibility layers. You will encounter fewer bugs with ProtocolSupport or the ViaVersion combo then you will running 7 year old software. I guarentee it.

#### Maven Repo
The 1.8.8 version will not build, because my old maven repo has been permanently shutdown.

### Porting Plugins
If you have a plugin that uses TacoSpgiot-specific APIs or custom events (in the `net.techcable.tacospigot` package), I am willing to offer my advice to help you port it. (See below)

I will not help porting any code that uses MC internals (net.minecraft.server).

To help with porting plugins, I have made one final maven release of the API, available [on my new maven repo](https://techcable.net/releases/maven/).

This does not include the server jar (or anything needed to build it). I will not offer that under any circumstances.

This was originally requsted by @regulad - Blame him for the failures

## Contact
If you need to discuss something with me or have questions about historical patches,
please ping me at `@Techcable#0536` on the Paper discord.

I am also (still) available on IRC at #techcable on esper.net ([webchat](https://webchat.esper.net/?join=techcable)).

To be clear, I will not help build or support 1.8.8 under any circumstances.

This will not change regardless of the amount of the money you offer me.

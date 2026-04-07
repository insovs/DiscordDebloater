# Discord Debloat and Optimization Tool - GUI v1.1
# Author: https://guns.lol/inso.vs | For personal use only / Redistribution prohibited.

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# --- CONSTANTS ---------------------------------------------------------------
$TOOL_VERSION  = "9.1"
$PREFS_PATH    = "$env:APPDATA\DiscordDebloatTool\prefs.json"
$UPDATE_URL    = "https://raw.githubusercontent.com/insovs/discord-debloat/main/version.txt"

$DISCORD_VARIANTS = @(
    [pscustomobject]@{ Name = "Discord Stable"; Path = "$env:LOCALAPPDATA\Discord"; AppData = "$env:APPDATA\discord" }
)

# --- PREFS -------------------------------------------------------------------
function Load-Prefs {
    if (Test-Path $PREFS_PATH) {
        try { return (Get-Content $PREFS_PATH -Raw | ConvertFrom-Json) } catch {}
    }
    return [pscustomobject]@{ lang = "en"; localStorage = $false }
}
function Save-Prefs($p) {
    $dir = Split-Path $PREFS_PATH
    if (-not (Test-Path $dir)) { New-Item $dir -ItemType Directory -Force | Out-Null }
    $p | ConvertTo-Json | Set-Content $PREFS_PATH -Force
}

$prefs = Load-Prefs

[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Discord Debloat Tool"
    Width="900" Height="680"
    MinWidth="780" MinHeight="560"
    WindowStartupLocation="CenterScreen"
    Background="Transparent"
    Foreground="#f2f3f5"
    FontFamily="Segoe UI"
    ResizeMode="CanResize"
    WindowStyle="None"
    AllowsTransparency="True">

  <WindowChrome.WindowChrome>
    <WindowChrome ResizeBorderThickness="8" CaptionHeight="0" CornerRadius="0"
                  GlassFrameThickness="0" NonClientFrameEdges="None"/>
  </WindowChrome.WindowChrome>

  <Window.Resources>

    <Style x:Key="ModernCheck" TargetType="CheckBox">
      <Setter Property="Foreground"  Value="#b5bac1"/>
      <Setter Property="FontFamily"  Value="Segoe UI"/>
      <Setter Property="FontSize"    Value="11"/>
      <Setter Property="Cursor"      Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="CheckBox">
            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
              <Border x:Name="box" Width="15" Height="15" CornerRadius="4"
                      Background="#1e1f22" BorderBrush="#20203a" BorderThickness="1"
                      VerticalAlignment="Center" Margin="0,0,10,0">
                <Rectangle x:Name="mark" Width="7" Height="7" RadiusX="2" RadiusY="2"
                           Fill="#6b7280" Visibility="Collapsed"
                           HorizontalAlignment="Center" VerticalAlignment="Center"/>
              </Border>
              <ContentPresenter VerticalAlignment="Center"/>
            </StackPanel>
            <ControlTemplate.Triggers>
              <Trigger Property="IsChecked" Value="True">
                <Setter TargetName="box"  Property="Background"  Value="#2a2b2e"/>
                <Setter TargetName="box"  Property="BorderBrush" Value="#6b7280"/>
                <Setter TargetName="mark" Property="Visibility"  Value="Visible"/>
              </Trigger>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="box" Property="BorderBrush" Value="#6b7280"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="LangRadio" TargetType="RadioButton">
      <Setter Property="Foreground"   Value="#b5bac1"/>
      <Setter Property="FontFamily"   Value="Segoe UI"/>
      <Setter Property="FontSize"     Value="11"/>
      <Setter Property="Cursor"       Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="RadioButton">
            <Border x:Name="bd" Background="#1e1f22" BorderBrush="#2e3035"
                    BorderThickness="1" CornerRadius="8" Padding="6,9">
              <StackPanel HorizontalAlignment="Center">
                <ContentPresenter HorizontalAlignment="Center"/>
              </StackPanel>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsChecked" Value="True">
                <Setter TargetName="bd" Property="Background"  Value="#26272a"/>
                <Setter TargetName="bd" Property="BorderBrush" Value="#6b7280"/>
              </Trigger>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bd" Property="BorderBrush" Value="#4b5563"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="PrimaryBtn" TargetType="Button">
      <Setter Property="Background"      Value="#3d3f44"/>
      <Setter Property="Foreground"      Value="#e3e5e8"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="FontFamily"      Value="Segoe UI"/>
      <Setter Property="FontSize"        Value="11"/>
      <Setter Property="FontWeight"      Value="SemiBold"/>
      <Setter Property="Cursor"          Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" Background="{TemplateBinding Background}"
                    CornerRadius="8" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bd" Property="Background" Value="#4b4d52"/>
              </Trigger>
              <Trigger Property="IsPressed" Value="True">
                <Setter TargetName="bd" Property="Background" Value="#2e3035"/>
              </Trigger>
              <Trigger Property="IsEnabled" Value="False">
                <Setter TargetName="bd" Property="Background" Value="#1a1a1e"/>
                <Setter Property="Foreground" Value="#40434a"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="AmberBtn" TargetType="Button">
      <Setter Property="Background"      Value="#3d3f44"/>
      <Setter Property="Foreground"      Value="#d1d5db"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="FontFamily"      Value="Segoe UI"/>
      <Setter Property="FontSize"        Value="11"/>
      <Setter Property="FontWeight"      Value="SemiBold"/>
      <Setter Property="Cursor"          Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" Background="{TemplateBinding Background}"
                    CornerRadius="8" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bd" Property="Background" Value="#4b4d52"/>
              </Trigger>
              <Trigger Property="IsPressed" Value="True">
                <Setter TargetName="bd" Property="Background" Value="#2e3035"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="GhostBtn" TargetType="Button">
      <Setter Property="Background"      Value="Transparent"/>
      <Setter Property="Foreground"      Value="#6b7280"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="BorderBrush"     Value="#2e3035"/>
      <Setter Property="FontFamily"      Value="Segoe UI"/>
      <Setter Property="FontSize"        Value="11"/>
      <Setter Property="Cursor"          Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" Background="{TemplateBinding Background}"
                    BorderBrush="{TemplateBinding BorderBrush}"
                    BorderThickness="{TemplateBinding BorderThickness}"
                    CornerRadius="8" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bd" Property="Background"  Value="#1e1f22"/>
                <Setter TargetName="bd" Property="BorderBrush" Value="#6b7280"/>
                <Setter Property="Foreground" Value="#b5bac1"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="DangerBtn" TargetType="Button">
      <Setter Property="Background"      Value="#8b1a1a"/>
      <Setter Property="Foreground"      Value="#f08080"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="FontFamily"      Value="Segoe UI"/>
      <Setter Property="FontSize"        Value="11"/>
      <Setter Property="FontWeight"      Value="SemiBold"/>
      <Setter Property="Cursor"          Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" Background="{TemplateBinding Background}"
                    CornerRadius="8" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bd" Property="Background" Value="#a52020"/>
              </Trigger>
              <Trigger Property="IsPressed" Value="True">
                <Setter TargetName="bd" Property="Background" Value="#6e1212"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="CardBtn" TargetType="Button">
      <Setter Property="Background"      Value="#0c0c14"/>
      <Setter Property="Foreground"      Value="#f2f3f5"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="BorderBrush"     Value="#2e3035"/>
      <Setter Property="FontFamily"      Value="Segoe UI"/>
      <Setter Property="Cursor"          Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" Background="{TemplateBinding Background}"
                    BorderBrush="{TemplateBinding BorderBrush}"
                    BorderThickness="{TemplateBinding BorderThickness}"
                    CornerRadius="12" Padding="{TemplateBinding Padding}">
              <ContentPresenter/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bd" Property="Background"  Value="#0e0e18"/>
                <Setter TargetName="bd" Property="BorderBrush" Value="#4b4d52"/>
              </Trigger>
              <Trigger Property="IsPressed" Value="True">
                <Setter TargetName="bd" Property="Background" Value="#0b0b14"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="TitleBarBtn" TargetType="Button">
      <Setter Property="Background"      Value="Transparent"/>
      <Setter Property="Foreground"      Value="#4e5058"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="FontFamily"      Value="Segoe UI"/>
      <Setter Property="FontSize"        Value="13"/>
      <Setter Property="Cursor"          Value="Hand"/>
      <Setter Property="Width"           Value="28"/>
      <Setter Property="Height"          Value="22"/>
      <Setter Property="WindowChrome.IsHitTestVisibleInChrome" Value="True"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" Background="{TemplateBinding Background}" CornerRadius="5">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bd" Property="Background" Value="#1e1f22"/>
                <Setter Property="Foreground" Value="#b5bac1"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="CloseBtn" TargetType="Button">
      <Setter Property="Background"      Value="Transparent"/>
      <Setter Property="Foreground"      Value="#4e5058"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="FontFamily"      Value="Segoe UI"/>
      <Setter Property="FontSize"        Value="11"/>
      <Setter Property="Cursor"          Value="Hand"/>
      <Setter Property="Width"           Value="28"/>
      <Setter Property="Height"          Value="22"/>
      <Setter Property="WindowChrome.IsHitTestVisibleInChrome" Value="True"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" Background="{TemplateBinding Background}" CornerRadius="5">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bd" Property="Background" Value="#c0392b"/>
                <Setter Property="Foreground" Value="White"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="ModalCloseBtn" TargetType="Button">
      <Setter Property="Background"      Value="Transparent"/>
      <Setter Property="Foreground"      Value="#4e5058"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="BorderBrush"     Value="#2e3035"/>
      <Setter Property="FontFamily"      Value="Segoe UI"/>
      <Setter Property="FontSize"        Value="11"/>
      <Setter Property="Cursor"          Value="Hand"/>
      <Setter Property="Width"           Value="28"/>
      <Setter Property="Height"          Value="28"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" Background="{TemplateBinding Background}"
                    BorderBrush="{TemplateBinding BorderBrush}"
                    BorderThickness="{TemplateBinding BorderThickness}"
                    CornerRadius="7">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bd" Property="Background"  Value="#1e1f22"/>
                <Setter TargetName="bd" Property="BorderBrush" Value="#6b7280"/>
                <Setter Property="Foreground" Value="#b5bac1"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="ScrollBarLineButton" TargetType="RepeatButton">
      <Setter Property="OverridesDefaultStyle" Value="True"/>
      <Setter Property="Focusable"             Value="False"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="RepeatButton">
            <Border Background="Transparent" Width="0" Height="0"/>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style x:Key="ScrollBarPageButton" TargetType="RepeatButton">
      <Setter Property="OverridesDefaultStyle" Value="True"/>
      <Setter Property="IsTabStop"             Value="False"/>
      <Setter Property="Focusable"             Value="False"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="RepeatButton">
            <Border Background="Transparent"/>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style x:Key="ScrollBarThumb" TargetType="Thumb">
      <Setter Property="OverridesDefaultStyle" Value="True"/>
      <Setter Property="IsTabStop"             Value="False"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Thumb">
            <Border x:Name="ThumbBd" CornerRadius="3" Background="#3d4045" Margin="2"/>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="ThumbBd" Property="Background" Value="#6b7280"/>
              </Trigger>
              <Trigger Property="IsDragging" Value="True">
                <Setter TargetName="ThumbBd" Property="Background" Value="#4b4d52"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <ControlTemplate x:Key="VerticalScrollBar" TargetType="ScrollBar">
      <Grid>
        <Grid.RowDefinitions>
          <RowDefinition Height="0"/>
          <RowDefinition Height="*"/>
          <RowDefinition Height="0"/>
        </Grid.RowDefinitions>
        <RepeatButton Grid.Row="0" Style="{StaticResource ScrollBarLineButton}" Height="0"/>
        <Track x:Name="PART_Track" Grid.Row="1" IsDirectionReversed="True">
          <Track.DecreaseRepeatButton><RepeatButton Style="{StaticResource ScrollBarPageButton}"/></Track.DecreaseRepeatButton>
          <Track.Thumb><Thumb Style="{StaticResource ScrollBarThumb}"/></Track.Thumb>
          <Track.IncreaseRepeatButton><RepeatButton Style="{StaticResource ScrollBarPageButton}"/></Track.IncreaseRepeatButton>
        </Track>
        <RepeatButton Grid.Row="2" Style="{StaticResource ScrollBarLineButton}" Height="0"/>
      </Grid>
    </ControlTemplate>
    <Style TargetType="ScrollBar">
      <Setter Property="OverridesDefaultStyle" Value="True"/>
      <Setter Property="SnapsToDevicePixels"   Value="True"/>
      <Setter Property="Background"            Value="Transparent"/>
      <Style.Triggers>
        <Trigger Property="Orientation" Value="Vertical">
          <Setter Property="Width"    Value="6"/>
          <Setter Property="MinWidth" Value="6"/>
          <Setter Property="Template" Value="{StaticResource VerticalScrollBar}"/>
        </Trigger>
      </Style.Triggers>
    </Style>
    <Style TargetType="ScrollViewer">
      <Setter Property="OverridesDefaultStyle" Value="True"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="ScrollViewer">
            <Grid>
              <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
              </Grid.ColumnDefinitions>
              <ScrollContentPresenter Grid.Column="0" Margin="{TemplateBinding Padding}"
                                      CanContentScroll="{TemplateBinding CanContentScroll}"/>
              <ScrollBar x:Name="PART_VerticalScrollBar" Grid.Column="1"
                         Orientation="Vertical"
                         Value="{TemplateBinding VerticalOffset}"
                         Maximum="{TemplateBinding ScrollableHeight}"
                         ViewportSize="{TemplateBinding ViewportHeight}"
                         Visibility="{TemplateBinding ComputedVerticalScrollBarVisibility}"/>
            </Grid>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <!-- OK Button style for SuccessOverlay -->
    <Style x:Key="SuccessOkBtn" TargetType="Button">
      <Setter Property="Background"      Value="#1e2024"/>
      <Setter Property="Foreground"      Value="#9ca3af"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="BorderBrush"     Value="#3d4045"/>
      <Setter Property="FontFamily"      Value="Segoe UI"/>
      <Setter Property="FontSize"        Value="11"/>
      <Setter Property="FontWeight"      Value="SemiBold"/>
      <Setter Property="Cursor"          Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" Background="{TemplateBinding Background}"
                    BorderBrush="{TemplateBinding BorderBrush}"
                    BorderThickness="{TemplateBinding BorderThickness}"
                    CornerRadius="8" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bd" Property="Background"  Value="#2e3035"/>
                <Setter TargetName="bd" Property="BorderBrush" Value="#6b7280"/>
              </Trigger>
              <Trigger Property="IsPressed" Value="True">
                <Setter TargetName="bd" Property="Background" Value="#16171a"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

  </Window.Resources>

  <Border x:Name="OuterBorder" Margin="8" CornerRadius="14"
          Background="#09090f" BorderBrush="#2e3035" BorderThickness="1"
          SnapsToDevicePixels="True">
    <Border.Effect>
      <DropShadowEffect Color="#000000" BlurRadius="24" ShadowDepth="0" Opacity="0.9"/>
    </Border.Effect>

    <Grid>
      <Grid.RowDefinitions>
        <RowDefinition Height="42"/>
        <RowDefinition Height="*"/>
        <RowDefinition Height="28"/>
      </Grid.RowDefinitions>

      <!-- TITLE BAR - texte neutre, sans couleur agressive -->
      <Border Grid.Row="0" x:Name="TitleBar"
              Background="#09090f" CornerRadius="14,14,0,0"
              BorderBrush="#2a2c30" BorderThickness="0,0,0,1">
        <Grid Margin="16,0,10,0">
          <StackPanel Orientation="Horizontal" VerticalAlignment="Center">

          </StackPanel>
          <Button x:Name="BtnGithub" HorizontalAlignment="Center" VerticalAlignment="Center"
                  Background="#1e1f22" BorderBrush="#2e3035" BorderThickness="1"
                  Cursor="Hand" Padding="12,4"
                  WindowChrome.IsHitTestVisibleInChrome="True">
            <Button.Template>
              <ControlTemplate TargetType="Button">
                <Border x:Name="bd" Background="{TemplateBinding Background}"
                        BorderBrush="{TemplateBinding BorderBrush}"
                        BorderThickness="{TemplateBinding BorderThickness}"
                        CornerRadius="6" Padding="{TemplateBinding Padding}">
                  <StackPanel Orientation="Horizontal">
                    <TextBlock x:Name="GhText" Text="github.com/insovs" Foreground="#4e5058" FontSize="9" FontFamily="Consolas"/>

                    <TextBlock x:Name="UpdateBadge" Text="" Foreground="#9ca3af"
                               FontSize="9" FontFamily="Consolas" Margin="6,0,0,0" Visibility="Collapsed"/>
                  </StackPanel>
                </Border>
                <ControlTemplate.Triggers>
                  <Trigger Property="IsMouseOver" Value="True">
                    <Setter TargetName="bd" Property="BorderBrush" Value="#6b7280"/>
                    <Setter TargetName="GhText" Property="Foreground" Value="#9ca3af"/>
                  </Trigger>
                </ControlTemplate.Triggers>
              </ControlTemplate>
            </Button.Template>
          </Button>
          <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center">
            <Button x:Name="BtnConsole" Style="{StaticResource TitleBarBtn}" Content="&gt;_" FontSize="9" FontFamily="Consolas"/>
            <Button x:Name="BtnMin"   Style="{StaticResource TitleBarBtn}" Content="-"  FontSize="14"/>
            <Button x:Name="BtnMax"   Style="{StaticResource TitleBarBtn}" Content="+" FontSize="10"/>
            <Button x:Name="BtnClose" Style="{StaticResource CloseBtn}"    Content="x" FontSize="10"/>
          </StackPanel>
        </Grid>
      </Border>

      <!-- MAIN CONTENT -->
      <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto" Padding="40,36,40,0">
        <StackPanel>

          <!-- HEADER -->
          <StackPanel HorizontalAlignment="Center" Margin="0,0,0,28">
            <Border HorizontalAlignment="Center" CornerRadius="18" Margin="0,0,0,16"
                    BorderBrush="#3d4045" BorderThickness="1.5"
                    Padding="32,10" Background="Transparent">
              <Border.Effect>
                <DropShadowEffect Color="#6b7280" BlurRadius="18" ShadowDepth="0" Opacity="0.15"/>
              </Border.Effect>
              <TextBlock Text="Discord Optimizer Tool" FontSize="26" FontWeight="Normal"
                         Foreground="#e3e5e8" HorizontalAlignment="Center"/>
            </Border>
            <TextBlock Text="Performance and Privacy Suite"
                       Foreground="#f2f3f5" FontSize="20" FontWeight="SemiBold"
                       HorizontalAlignment="Center" Margin="0,0,0,8"/>
            <TextBlock Foreground="#4e5058" FontSize="11.5" TextAlignment="Center"
                       HorizontalAlignment="Center" TextWrapping="Wrap" MaxWidth="460"
                       LineHeight="20"
                       Text="Removes unnecessary files, modules, caches and resource-intensive features&#xa;to significantly reduce Discord's RAM and CPU usage."/>
          </StackPanel>

          <!-- Variant selector hidden (stable only) -->
          <Border Visibility="Collapsed">
            <StackPanel>
              <RadioButton x:Name="RdVarStable" GroupName="Variant" IsChecked="True"/>
            </StackPanel>
          </Border>

          <!-- THREE CARDS - meme couleur grise uniforme -->
          <Grid Margin="0,0,0,0">
            <Grid.ColumnDefinitions>
              <ColumnDefinition Width="*"/>
              <ColumnDefinition Width="10"/>
              <ColumnDefinition Width="*"/>
              <ColumnDefinition Width="10"/>
              <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>

            <!-- CARD 1: Debloat -->
            <Button Grid.Column="0" x:Name="BtnOpenDebloat" Style="{StaticResource CardBtn}" Padding="20">
              <StackPanel>
                <Grid Margin="0,0,0,14">
                  <Border Height="32" CornerRadius="9" Background="#1e1f22" BorderBrush="#3d4045" BorderThickness="1" Padding="14,0" HorizontalAlignment="Left">
                    <TextBlock Text="Debloat" FontSize="14" HorizontalAlignment="Center" VerticalAlignment="Center" Foreground="#d1d5db" FontWeight="SemiBold"/>
                  </Border>
                  <TextBlock Text=">" HorizontalAlignment="Right" Foreground="#36393f" FontSize="16" VerticalAlignment="Center"/>
                </Grid>
                <TextBlock Foreground="#4e5058" FontSize="10.5" TextWrapping="Wrap" LineHeight="16" Margin="0,0,0,12"
                           Text="Removes old versions, unused modules, language packs, and heavy components to optimize your installation and improve performance compared to the original Discord."/>
                <WrapPanel>
                  <Border CornerRadius="4" Margin="0,0,4,4" Padding="7,2" Background="#1a1b1e" BorderBrush="#2e3035" BorderThickness="1">
                    <TextBlock Text="modules" Foreground="#40444b" FontSize="9" FontFamily="Consolas"/>
                  </Border>
                  <Border CornerRadius="4" Margin="0,0,4,4" Padding="7,2" Background="#1a1b1e" BorderBrush="#2e3035" BorderThickness="1">
                    <TextBlock Text="lang packs" Foreground="#40444b" FontSize="9" FontFamily="Consolas"/>
                  </Border>
                  <Border CornerRadius="4" Margin="0,0,4,4" Padding="7,2" Background="#1a1b1e" BorderBrush="#2e3035" BorderThickness="1">
                    <TextBlock Text="krisp" Foreground="#40444b" FontSize="9" FontFamily="Consolas"/>
                  </Border>
                  <Border CornerRadius="4" Padding="7,2" Background="#1a1b1e" BorderBrush="#2e3035" BorderThickness="1">
                    <TextBlock Text="updater" Foreground="#40444b" FontSize="9" FontFamily="Consolas"/>
                  </Border>
                  <Border CornerRadius="4" Margin="4,4,0,0" Padding="7,2" Background="#1a1b1e" BorderBrush="#2e3035" BorderThickness="1">
                    <TextBlock Text="autostart" Foreground="#40444b" FontSize="9" FontFamily="Consolas"/>
                  </Border>
                  <Border CornerRadius="4" Margin="4,4,0,0" Padding="7,2" Background="#1a1b1e" BorderBrush="#2e3035" BorderThickness="1">
                    <TextBlock Text="FSO" Foreground="#40444b" FontSize="9" FontFamily="Consolas"/>
                  </Border>
                </WrapPanel>
              </StackPanel>
            </Button>

            <!-- CARD 2: Opt. Settings - meme style gris que Debloat -->
            <Button Grid.Column="2" x:Name="BtnOpenSettings" Style="{StaticResource CardBtn}" Padding="20">
              <StackPanel>
                <Grid Margin="0,0,0,14">
                  <Border Height="32" CornerRadius="9" Background="#1e1f22" BorderBrush="#3d4045" BorderThickness="1" Padding="14,0" HorizontalAlignment="Left">
                    <TextBlock Text="Opt. Settings" FontSize="14" HorizontalAlignment="Center" VerticalAlignment="Center" Foreground="#d1d5db" FontWeight="SemiBold"/>
                  </Border>
                  <TextBlock Text=">" HorizontalAlignment="Right" Foreground="#36393f" FontSize="16" VerticalAlignment="Center"/>
                </Grid>
                <TextBlock Foreground="#4e5058" FontSize="10.5" TextWrapping="Wrap" LineHeight="16" Margin="0,0,0,12"
                           Text="Applies a performance-focused settings.json to disable hardware acceleration, reduce logging, and prevent unnecessary background processes such as auto-updates."/>
                <WrapPanel>
                  <Border CornerRadius="4" Margin="0,0,4,4" Padding="7,2" Background="#1a1b1e" BorderBrush="#2e3035" BorderThickness="1">
                    <TextBlock Text="HW accel" Foreground="#40444b" FontSize="9" FontFamily="Consolas"/>
                  </Border>
                  <Border CornerRadius="4" Margin="0,0,4,4" Padding="7,2" Background="#1a1b1e" BorderBrush="#2e3035" BorderThickness="1">
                    <TextBlock Text="dev mode" Foreground="#40444b" FontSize="9" FontFamily="Consolas"/>
                  </Border>
                  <Border CornerRadius="4" Margin="0,0,4,4" Padding="7,2" Background="#1a1b1e" BorderBrush="#2e3035" BorderThickness="1">
                    <TextBlock Text="tray" Foreground="#40444b" FontSize="9" FontFamily="Consolas"/>
                  </Border>
                  <Border CornerRadius="4" Padding="7,2" Background="#1a1b1e" BorderBrush="#2e3035" BorderThickness="1">
                    <TextBlock Text="debug log" Foreground="#40444b" FontSize="9" FontFamily="Consolas"/>
                  </Border>
                </WrapPanel>
              </StackPanel>
            </Button>

            <!-- CARD 3: Clean Cache - meme style gris que les deux autres -->
            <Button Grid.Column="4" x:Name="BtnOpenCache" Style="{StaticResource CardBtn}" Padding="20">
              <StackPanel>
                <Grid Margin="0,0,0,14">
                  <Border Height="32" CornerRadius="9" Background="#1e1f22" BorderBrush="#3d4045" BorderThickness="1" Padding="14,0" HorizontalAlignment="Left">
                    <TextBlock Text="Clean Cache" FontSize="14" HorizontalAlignment="Center" VerticalAlignment="Center" Foreground="#d1d5db" FontWeight="SemiBold"/>
                  </Border>
                  <TextBlock Text=">" HorizontalAlignment="Right" Foreground="#36393f" FontSize="16" VerticalAlignment="Center"/>
                </Grid>
                <TextBlock Foreground="#4e5058" FontSize="10.5" TextWrapping="Wrap" LineHeight="16" Margin="0,0,0,12"
                           Text="Clears GPU cache, cookies, crash reports, and Sentry tracking data to free up disk space and improve overall application responsiveness."/>
                <WrapPanel>
                  <Border CornerRadius="4" Margin="0,0,4,4" Padding="7,2" Background="#1a1b1e" BorderBrush="#2e3035" BorderThickness="1">
                    <TextBlock Text="cache" Foreground="#40444b" FontSize="9" FontFamily="Consolas"/>
                  </Border>
                  <Border CornerRadius="4" Margin="0,0,4,4" Padding="7,2" Background="#1a1b1e" BorderBrush="#2e3035" BorderThickness="1">
                    <TextBlock Text="gpu cache" Foreground="#40444b" FontSize="9" FontFamily="Consolas"/>
                  </Border>
                  <Border CornerRadius="4" Margin="0,0,4,4" Padding="7,2" Background="#1a1b1e" BorderBrush="#2e3035" BorderThickness="1">
                    <TextBlock Text="crashpad" Foreground="#40444b" FontSize="9" FontFamily="Consolas"/>
                  </Border>
                  <Border CornerRadius="4" Padding="7,2" Background="#1a1b1e" BorderBrush="#2e3035" BorderThickness="1">
                    <TextBlock Text="sentry" Foreground="#40444b" FontSize="9" FontFamily="Consolas"/>
                  </Border>
                </WrapPanel>
              </StackPanel>
            </Button>

          </Grid>
        </StackPanel>
      </ScrollViewer>

      <Border Grid.Row="2" Background="#0e0f11" BorderBrush="#2a2c30" BorderThickness="0,1,0,0"
              CornerRadius="0,0,14,14" Padding="28,0">
        <Grid>
          <TextBlock Text="https://github.com/insovs/Discord-Optimization" VerticalAlignment="Center"
                     FontSize="9" FontFamily="Consolas" Foreground="#2e3035"/>
          <TextBlock x:Name="StatusBarText2" HorizontalAlignment="Right" VerticalAlignment="Center"
                     Foreground="#6b7280" FontSize="9" FontFamily="Consolas" Text="Discord  version: not found"/>
        </Grid>
      </Border>

      <!-- MODAL OVERLAY -->
      <Grid x:Name="ModalOverlay" Grid.Row="0" Grid.RowSpan="3"
            Visibility="Collapsed" Background="#c8000005">

        <!-- DEBLOAT PANEL -->
        <Border x:Name="PanelDebloat" Visibility="Collapsed"
                HorizontalAlignment="Center" VerticalAlignment="Center"
                Width="540" MaxHeight="600"
                Background="#18191c" BorderBrush="#2e3035" BorderThickness="1"
                CornerRadius="16">
          <Border.Effect>
            <DropShadowEffect Color="#000000" BlurRadius="60" ShadowDepth="0" Opacity="0.85"/>
          </Border.Effect>
          <Grid>
            <Grid.RowDefinitions>
              <RowDefinition Height="Auto"/>
              <RowDefinition Height="*"/>
              <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <Border Grid.Row="0" BorderBrush="#2e3035" BorderThickness="0,0,0,1"
                    Padding="24,20,24,16" CornerRadius="16,16,0,0">
              <Grid>
                <StackPanel Orientation="Horizontal">
                  <Border Width="36" Height="36" CornerRadius="10" Margin="0,0,12,0"
                          Background="#1e1f22" BorderBrush="#3d4045" BorderThickness="1">
                    <Viewbox Width="15" Height="15" HorizontalAlignment="Center" VerticalAlignment="Center">
                      <Path Fill="#9ca3af" Data="M9 3H7C6.4 3 6 3.4 6 4v1H3v2h1l1 13h12l1-13h1V5h-3V4c0-.6-.4-1-1-1h-2c-.6 0-1 .4-1 1v1H9V4c0-.6-.4-1-1-1zm0 2v-1h2v1H9zm-2 3h2v9H7V8zm4 0h2v9h-2V8z" Stretch="Uniform"/>
                    </Viewbox>
                  </Border>
                  <StackPanel VerticalAlignment="Center">
                    <TextBlock Text="Debloat" Foreground="#e3e5e8" FontSize="14" FontWeight="SemiBold"/>
                    <TextBlock x:Name="DbSelectedVariant" Text="Removes unused modules, old versions and heavy files" Foreground="#4e5058" FontSize="10" Margin="0,3,0,0"/>
                  </StackPanel>
                </StackPanel>
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center">
                  <Button x:Name="BtnOpenAdvanced" Content="Advanced"
                          Height="28" Padding="12,0" Margin="0,0,8,0"
                          FontSize="10" FontFamily="Segoe UI" Cursor="Hand"
                          Background="Transparent" Foreground="#4e5058"
                          BorderThickness="1" BorderBrush="#2e3035">
                    <Button.Template>
                      <ControlTemplate TargetType="Button">
                        <Border x:Name="bd" Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="7" Padding="{TemplateBinding Padding}">
                          <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                          <Trigger Property="IsMouseOver" Value="True">
                            <Setter TargetName="bd" Property="Background"  Value="#1e1f22"/>
                            <Setter TargetName="bd" Property="BorderBrush" Value="#6b7280"/>
                            <Setter Property="Foreground" Value="#b5bac1"/>
                          </Trigger>
                        </ControlTemplate.Triggers>
                      </ControlTemplate>
                    </Button.Template>
                  </Button>
                  <Button x:Name="BtnCloseDebloat" Style="{StaticResource ModalCloseBtn}" Content="x"/>
                </StackPanel>
              </Grid>
            </Border>

            <ScrollViewer Grid.Row="1" x:Name="DbPage1Scroll" VerticalScrollBarVisibility="Auto" Padding="24,20,24,4">
              <StackPanel x:Name="DbPage1">


                <Border CornerRadius="8" Background="#1e1f22" BorderBrush="#3d4045"
                        BorderThickness="1" Padding="12,9" Margin="0,0,0,14">
                  <StackPanel Orientation="Horizontal">
                    <TextBlock Text="i  " Foreground="#6b7280" FontSize="11" VerticalAlignment="Center"/>
                    <TextBlock Text="Click Advanced to customize what gets removed before running."
                               Foreground="#4e5058" FontSize="10"/>
                  </StackPanel>
                </Border>

                <TextBlock Text="LANGUAGE PACK TO KEEP" Foreground="#3d4045" FontSize="9"
                           FontFamily="Consolas" FontWeight="Bold" Margin="0,0,0,10"/>

                <Grid Margin="0,0,0,14">
                  <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="6"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="6"/>
                    <ColumnDefinition Width="*"/>
                  </Grid.ColumnDefinitions>
                  <RadioButton x:Name="RdLangEN" Grid.Column="0" Style="{StaticResource LangRadio}" GroupName="Lang" IsChecked="True">
                    <StackPanel HorizontalAlignment="Center">
                      <TextBlock Text="English" HorizontalAlignment="Center" FontSize="11" FontWeight="Medium" Foreground="#b5bac1"/>
                      <TextBlock Text="en-US" HorizontalAlignment="Center" FontSize="9.5" Foreground="#4e5058" FontFamily="Consolas" Margin="0,3,0,0"/>
                    </StackPanel>
                  </RadioButton>
                  <RadioButton x:Name="RdLangFR" Grid.Column="2" Style="{StaticResource LangRadio}" GroupName="Lang">
                    <StackPanel HorizontalAlignment="Center">
                      <TextBlock Text="French" HorizontalAlignment="Center" FontSize="11" FontWeight="Medium" Foreground="#b5bac1"/>
                      <TextBlock Text="fr-FR" HorizontalAlignment="Center" FontSize="9.5" Foreground="#4e5058" FontFamily="Consolas" Margin="0,3,0,0"/>
                    </StackPanel>
                  </RadioButton>
                  <RadioButton x:Name="RdLangBoth" Grid.Column="4" Style="{StaticResource LangRadio}" GroupName="Lang">
                    <StackPanel HorizontalAlignment="Center">
                      <TextBlock Text="Both" HorizontalAlignment="Center" FontSize="11" FontWeight="Medium" Foreground="#b5bac1"/>
                      <TextBlock Text="en + fr" HorizontalAlignment="Center" FontSize="9.5" Foreground="#4e5058" FontFamily="Consolas" Margin="0,3,0,0"/>
                    </StackPanel>
                  </RadioButton>
                </Grid>


              </StackPanel>
            </ScrollViewer>

            <ScrollViewer Grid.Row="1" x:Name="DbPage2Scroll" VerticalScrollBarVisibility="Auto" Padding="24,20,24,4"
                          Visibility="Collapsed">
              <StackPanel x:Name="DbPage2">
                <Grid Margin="0,0,0,8">
                  <TextBlock x:Name="DbProgressLabel" Text="Initializing..."
                             Foreground="#4e5058" FontSize="9.5" FontFamily="Consolas"/>
                  <TextBlock x:Name="DbProgressPct" Text="0%"
                             Foreground="#4e5058" FontSize="9.5" FontFamily="Consolas" HorizontalAlignment="Right"/>
                </Grid>
                <Border Height="3" CornerRadius="2" Background="#111120" Margin="0,0,0,16">
                  <Grid>
                    <Border x:Name="DbProgressFill" HorizontalAlignment="Left" Width="0"
                            Background="#6b7280" CornerRadius="2"/>
                  </Grid>
                </Border>
                <ScrollViewer x:Name="DbLogScroll" VerticalScrollBarVisibility="Auto"
                              MaxHeight="260" Padding="0,0,4,0">
                  <StackPanel x:Name="DbLogPanel"/>
                </ScrollViewer>
              </StackPanel>
            </ScrollViewer>

            <Border Grid.Row="2" x:Name="DbFooter" BorderBrush="#2e3035"
                    BorderThickness="0,1,0,0" Padding="24,14" CornerRadius="0,0,16,16">
              <Grid>
                <StackPanel x:Name="DbBtnRunGroup" Orientation="Horizontal" HorizontalAlignment="Right">
                  <Button x:Name="BtnDbCancel" Content="Cancel"
                          Style="{StaticResource GhostBtn}" Height="34" Padding="18,0" Margin="0,0,8,0"/>
                  <Button x:Name="BtnDbRun" Content="Run Debloat"
                          Style="{StaticResource PrimaryBtn}" Height="34" Padding="18,0"/>
                </StackPanel>
                <StackPanel x:Name="DbBtnRunningGroup" Orientation="Horizontal" HorizontalAlignment="Right"
                            Visibility="Collapsed">
                  <Button x:Name="BtnDbStop" Content="Stop"
                          Style="{StaticResource DangerBtn}" Height="34" Padding="18,0"/>
                </StackPanel>
                <StackPanel x:Name="DbBtnDoneGroup" Orientation="Horizontal" HorizontalAlignment="Right"
                            Visibility="Collapsed">
                  <Button x:Name="BtnDbReturn" Content="Return to menu"
                          Style="{StaticResource GhostBtn}" Height="34" Padding="18,0"/>
                </StackPanel>
              </Grid>
            </Border>
          </Grid>
        </Border>

        <!-- SETTINGS PANEL -->
        <Border x:Name="PanelSettings" Visibility="Collapsed"
                HorizontalAlignment="Center" VerticalAlignment="Center"
                Width="520" MaxHeight="580"
                Background="#18191c" BorderBrush="#2e3035" BorderThickness="1"
                CornerRadius="16">
          <Border.Effect>
            <DropShadowEffect Color="#000000" BlurRadius="60" ShadowDepth="0" Opacity="0.85"/>
          </Border.Effect>
          <Grid>
            <Grid.RowDefinitions>
              <RowDefinition Height="Auto"/>
              <RowDefinition Height="Auto"/>
              <RowDefinition Height="*"/>
              <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <Border Grid.Row="0" BorderBrush="#2e3035" BorderThickness="0,0,0,1"
                    Padding="24,20,24,16" CornerRadius="16,16,0,0">
              <Grid>
                <StackPanel Orientation="Horizontal">
                  <Border Width="36" Height="36" CornerRadius="10" Margin="0,0,12,0"
                          Background="#1e1f22" BorderBrush="#3d4045" BorderThickness="1">
                    <TextBlock Text="O" FontSize="15" HorizontalAlignment="Center" VerticalAlignment="Center" Foreground="#9ca3af"/>
                  </Border>
                  <StackPanel VerticalAlignment="Center">
                    <TextBlock Text="Optimize Settings" Foreground="#e3e5e8" FontSize="14" FontWeight="SemiBold"/>
                    <TextBlock Text="Applies optimized settings.json: HW accel, logging, startup" Foreground="#4e5058" FontSize="10" Margin="0,3,0,0"/>
                  </StackPanel>
                </StackPanel>
                <Button x:Name="BtnCloseSettings" HorizontalAlignment="Right" VerticalAlignment="Center"
                        Style="{StaticResource ModalCloseBtn}" Content="x"/>
              </Grid>
            </Border>

            <Border Grid.Row="1" BorderBrush="#2e3035" BorderThickness="0,0,0,1" Padding="24,0,24,0">
              <StackPanel Orientation="Horizontal">
                <Button x:Name="TabStPreview" Height="38" Padding="14,0" FontSize="10.5"
                        Background="Transparent" BorderThickness="0,0,0,2" BorderBrush="#6b7280"
                        Foreground="#9ca3af" Cursor="Hand" FontFamily="Segoe UI">
                  <Button.Template>
                    <ControlTemplate TargetType="Button">
                      <Border x:Name="bd" BorderBrush="{TemplateBinding BorderBrush}"
                              BorderThickness="{TemplateBinding BorderThickness}" Padding="{TemplateBinding Padding}">
                        <ContentPresenter VerticalAlignment="Center"/>
                      </Border>
                    </ControlTemplate>
                  </Button.Template>
                  Preview
                </Button>
                <Button x:Name="TabStJson" Height="38" Padding="14,0" FontSize="10.5"
                        Background="Transparent" BorderThickness="0,0,0,2" BorderBrush="Transparent"
                        Foreground="#4e5058" Cursor="Hand" FontFamily="Segoe UI">
                  <Button.Template>
                    <ControlTemplate TargetType="Button">
                      <Border x:Name="bd" BorderBrush="{TemplateBinding BorderBrush}"
                              BorderThickness="{TemplateBinding BorderThickness}" Padding="{TemplateBinding Padding}">
                        <ContentPresenter VerticalAlignment="Center"/>
                      </Border>
                    </ControlTemplate>
                  </Button.Template>
                  JSON
                </Button>
              </StackPanel>
            </Border>

            <ScrollViewer Grid.Row="2" x:Name="StPagePreview" VerticalScrollBarVisibility="Auto" Padding="24,20,24,4">
              <StackPanel>
                <TextBlock Text="WHAT WILL BE APPLIED" Foreground="#3d4045" FontSize="9"
                           FontFamily="Consolas" FontWeight="Bold" Margin="0,0,0,10"/>
                <Border CornerRadius="10" Background="#1e1f22" BorderBrush="#2e3035" BorderThickness="1">
                  <StackPanel>
                    <Grid Margin="14,12,14,12">
                      <StackPanel>
                        <TextBlock Text="Disable Hardware Acceleration" Foreground="#dcddde" FontSize="11" FontWeight="Medium"/>
                        <TextBlock Text="Reduces GPU usage, better CPU performance on most systems" Foreground="#4e5058" FontSize="10" Margin="0,2,0,0"/>
                      </StackPanel>
                      <Border HorizontalAlignment="Right" VerticalAlignment="Center" Width="34" Height="18" CornerRadius="9" Background="#3d4045" BorderBrush="#4b4d52" BorderThickness="1">
                        <Ellipse Width="12" Height="12" Fill="White" HorizontalAlignment="Right" Margin="0,0,2,0"/>
                      </Border>
                    </Grid>
                    <Border Background="#16171a" Height="1" Margin="14,0"/>
                    <Grid Margin="14,12,14,12">
                      <StackPanel>
                        <TextBlock Text="Enable Developer Mode" Foreground="#dcddde" FontSize="11" FontWeight="Medium"/>
                        <TextBlock Text="Exposes additional debugging tools in Discord" Foreground="#4e5058" FontSize="10" Margin="0,2,0,0"/>
                      </StackPanel>
                      <Border HorizontalAlignment="Right" VerticalAlignment="Center" Width="34" Height="18" CornerRadius="9" Background="#3d4045" BorderBrush="#4b4d52" BorderThickness="1">
                        <Ellipse Width="12" Height="12" Fill="White" HorizontalAlignment="Right" Margin="0,0,2,0"/>
                      </Border>
                    </Grid>
                    <Border Background="#16171a" Height="1" Margin="14,0"/>
                    <Grid Margin="14,12,14,12">
                      <StackPanel>
                        <TextBlock Text="Skip Host Auto-Updates" Foreground="#dcddde" FontSize="11" FontWeight="Medium"/>
                        <TextBlock Text="Prevents automatic update checks on launch" Foreground="#4e5058" FontSize="10" Margin="0,2,0,0"/>
                      </StackPanel>
                      <Border HorizontalAlignment="Right" VerticalAlignment="Center" Width="34" Height="18" CornerRadius="9" Background="#3d4045" BorderBrush="#4b4d52" BorderThickness="1">
                        <Ellipse Width="12" Height="12" Fill="White" HorizontalAlignment="Right" Margin="0,0,2,0"/>
                      </Border>
                    </Grid>
                    <Border Background="#16171a" Height="1" Margin="14,0"/>
                    <Grid Margin="14,12,14,12">
                      <StackPanel>
                        <TextBlock Text="Minimize to System Tray" Foreground="#dcddde" FontSize="11" FontWeight="Medium"/>
                        <TextBlock Text="Discord hides to tray instead of closing" Foreground="#4e5058" FontSize="10" Margin="0,2,0,0"/>
                      </StackPanel>
                      <Border HorizontalAlignment="Right" VerticalAlignment="Center" Width="34" Height="18" CornerRadius="9" Background="#3d4045" BorderBrush="#4b4d52" BorderThickness="1">
                        <Ellipse Width="12" Height="12" Fill="White" HorizontalAlignment="Right" Margin="0,0,2,0"/>
                      </Border>
                    </Grid>
                    <Border Background="#16171a" Height="1" Margin="14,0"/>
                    <Grid Margin="14,12,14,12">
                      <StackPanel>
                        <TextBlock Text="Disable Debug Logging" Foreground="#dcddde" FontSize="11" FontWeight="Medium"/>
                        <TextBlock Text="Stops writing verbose debug logs to disk" Foreground="#4e5058" FontSize="10" Margin="0,2,0,0"/>
                      </StackPanel>
                      <Border HorizontalAlignment="Right" VerticalAlignment="Center" Width="34" Height="18" CornerRadius="9" Background="#3d4045" BorderBrush="#4b4d52" BorderThickness="1">
                        <Ellipse Width="12" Height="12" Fill="White" HorizontalAlignment="Right" Margin="0,0,2,0"/>
                      </Border>
                    </Grid>
                    <Border Background="#16171a" Height="1" Margin="14,0"/>
                    <Grid Margin="14,12,14,12">
                      <StackPanel>
                        <TextBlock Text="Optimized Startup Behavior" Foreground="#dcddde" FontSize="11" FontWeight="Medium"/>
                        <TextBlock Text="Maximized window, not minimized on start" Foreground="#4e5058" FontSize="10" Margin="0,2,0,0"/>
                      </StackPanel>
                      <Border HorizontalAlignment="Right" VerticalAlignment="Center" Width="34" Height="18" CornerRadius="9" Background="#3d4045" BorderBrush="#4b4d52" BorderThickness="1">
                        <Ellipse Width="12" Height="12" Fill="White" HorizontalAlignment="Right" Margin="0,0,2,0"/>
                      </Border>
                    </Grid>
                  </StackPanel>
                </Border>
              </StackPanel>
            </ScrollViewer>

            <ScrollViewer Grid.Row="2" x:Name="StPageJson" Visibility="Collapsed"
                          VerticalScrollBarVisibility="Auto" Padding="24,20,24,4">
              <StackPanel>
                <Border CornerRadius="9" Background="#0e0f11" BorderBrush="#2e3035" BorderThickness="1" Padding="14,12">
                  <StackPanel>
                    <TextBlock x:Name="StJsonPath" Text="%APPDATA%\discord\settings.json" Foreground="#3d4045"
                               FontSize="9" FontFamily="Consolas" Margin="0,0,0,8"/>
                    <TextBlock FontFamily="Cascadia Code, Consolas" FontSize="10.5" LineHeight="19"
                               Text="{}{&#10;  &quot;SKIP_HOST_UPDATE&quot;: true,&#10;  &quot;DEVELOPER_MODE&quot;: true,&#10;  &quot;enableHardwareAcceleration&quot;: false,&#10;  &quot;MINIMIZE_TO_TRAY&quot;: true,&#10;  &quot;IS_MAXIMIZED&quot;: true,&#10;  &quot;OPEN_ON_STARTUP&quot;: false,&#10;  &quot;START_MINIMIZED&quot;: false,&#10;  &quot;IS_MINIMIZED&quot;: false,&#10;  &quot;debugLogging&quot;: false&#10;}"
                               Foreground="#6b7280"/>
                  </StackPanel>
                </Border>
              </StackPanel>
            </ScrollViewer>

            <ScrollViewer Grid.Row="2" x:Name="StPage2" Visibility="Collapsed"
                          VerticalScrollBarVisibility="Auto" Padding="24,20,24,4">
              <StackPanel>
                <Grid Margin="0,0,0,8">
                  <TextBlock x:Name="StProgressLabel" Text="Applying..."
                             Foreground="#4e5058" FontSize="9.5" FontFamily="Consolas"/>
                  <TextBlock x:Name="StProgressPct" Text="0%"
                             Foreground="#4e5058" FontSize="9.5" FontFamily="Consolas" HorizontalAlignment="Right"/>
                </Grid>
                <Border Height="3" CornerRadius="2" Background="#111120" Margin="0,0,0,16">
                  <Grid>
                    <Border x:Name="StProgressFill" HorizontalAlignment="Left" Width="0"
                            Background="#6b7280" CornerRadius="2"/>
                  </Grid>
                </Border>
                <ScrollViewer x:Name="StLogScroll" VerticalScrollBarVisibility="Auto"
                              MaxHeight="220" Padding="0,0,4,0">
                  <StackPanel x:Name="StLogPanel"/>
                </ScrollViewer>
              </StackPanel>
            </ScrollViewer>

            <Border Grid.Row="3" x:Name="StFooter" BorderBrush="#2e3035"
                    BorderThickness="0,1,0,0" Padding="24,14" CornerRadius="0,0,16,16">
              <Grid>
                <StackPanel x:Name="StBtnApplyGroup" Orientation="Horizontal" HorizontalAlignment="Right">
                  <Button x:Name="BtnStCancel" Content="Cancel"
                          Style="{StaticResource GhostBtn}" Height="34" Padding="18,0" Margin="0,0,8,0"/>
                  <Button x:Name="BtnStApply" Content="Apply Settings"
                          Style="{StaticResource PrimaryBtn}" Height="34" Padding="18,0"/>
                </StackPanel>
                <StackPanel x:Name="StBtnDoneGroup" Orientation="Horizontal" HorizontalAlignment="Right"
                            Visibility="Collapsed">
                  <Button x:Name="BtnStReturn" Content="Return to menu"
                          Style="{StaticResource GhostBtn}" Height="34" Padding="18,0"/>
                </StackPanel>
              </Grid>
            </Border>
          </Grid>
        </Border>

        <!-- CACHE PANEL -->
        <Border x:Name="PanelCache" Visibility="Collapsed"
                HorizontalAlignment="Center" VerticalAlignment="Center"
                Width="520" MaxHeight="580"
                Background="#18191c" BorderBrush="#2e3035" BorderThickness="1"
                CornerRadius="16">
          <Border.Effect>
            <DropShadowEffect Color="#000000" BlurRadius="60" ShadowDepth="0" Opacity="0.85"/>
          </Border.Effect>
          <Grid>
            <Grid.RowDefinitions>
              <RowDefinition Height="Auto"/>
              <RowDefinition Height="*"/>
              <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <Border Grid.Row="0" BorderBrush="#2e3035" BorderThickness="0,0,0,1"
                    Padding="24,20,24,16" CornerRadius="16,16,0,0">
              <Grid>
                <StackPanel Orientation="Horizontal">
                  <Border Width="36" Height="36" CornerRadius="10" Margin="0,0,12,0"
                          Background="#1e1f22" BorderBrush="#3d4045" BorderThickness="1">
                    <TextBlock Text="#" FontSize="15" HorizontalAlignment="Center" VerticalAlignment="Center" Foreground="#9ca3af"/>
                  </Border>
                  <StackPanel VerticalAlignment="Center">
                    <TextBlock Text="Clean Cache and Logs" Foreground="#e3e5e8" FontSize="14" FontWeight="SemiBold"/>
                    <TextBlock Text="Clears GPU cache, cookies, crashpad and tracking data" Foreground="#4e5058" FontSize="10" Margin="0,3,0,0"/>
                  </StackPanel>
                </StackPanel>
                <Button x:Name="BtnCloseCache" HorizontalAlignment="Right" VerticalAlignment="Center"
                        Style="{StaticResource ModalCloseBtn}" Content="x"/>
              </Grid>
            </Border>

            <ScrollViewer Grid.Row="1" x:Name="CaPage1Scroll" VerticalScrollBarVisibility="Auto" Padding="24,20,24,4">
              <StackPanel x:Name="CaPage1">
                <Border CornerRadius="8" Background="#1a1a1e" BorderBrush="#2e3035"
                        BorderThickness="1" Padding="12,9" Margin="0,0,0,16">
                  <StackPanel Orientation="Horizontal">
                    <TextBlock Text="!  " Foreground="#9ca3af" FontSize="11" VerticalAlignment="Center"/>
                    <TextBlock Text="Some Discord settings may be reset after cleaning."
                               Foreground="#5a5f6a" FontSize="10.5"/>
                  </StackPanel>
                </Border>
                <TextBlock Text="WHAT WILL BE REMOVED" Foreground="#3d4045" FontSize="9"
                           FontFamily="Consolas" FontWeight="Bold" Margin="0,0,0,10"/>
                <Border CornerRadius="10" Background="#1e1f22" BorderBrush="#2e3035"
                        BorderThickness="1" Margin="0,0,0,16">
                  <StackPanel>
                    <StackPanel Margin="14,12,14,12">
                      <TextBlock Text="Cache and GPU Cache" Foreground="#b5bac1" FontSize="11" FontWeight="Medium"/>
                      <TextBlock Text="Cache / Code Cache / GPUCache / ShaderCache / VideoDecodeStats" Foreground="#4e5058" FontSize="10" Margin="0,3,0,0" TextWrapping="Wrap"/>
                    </StackPanel>
                    <Border Background="#16171a" Height="1" Margin="14,0"/>
                    <StackPanel Margin="14,12,14,12">
                      <TextBlock Text="Browser Data" Foreground="#b5bac1" FontSize="11" FontWeight="Medium"/>
                      <TextBlock Text="Cookies / Web Data / Databases / Session Storage" Foreground="#4e5058" FontSize="10" Margin="0,3,0,0" TextWrapping="Wrap"/>
                    </StackPanel>
                    <Border Background="#16171a" Height="1" Margin="14,0"/>
                    <StackPanel Margin="14,12,14,12">
                      <TextBlock Text="Logs and Crash Reports" Foreground="#b5bac1" FontSize="11" FontWeight="Medium"/>
                      <TextBlock Text="logs / Crashpad / debug / sentry error tracking" Foreground="#4e5058" FontSize="10" Margin="0,3,0,0" TextWrapping="Wrap"/>
                    </StackPanel>
                    <Border Background="#16171a" Height="1" Margin="14,0"/>
                    <StackPanel Margin="14,12,14,12">
                      <TextBlock Text="DRM and Tracking" Foreground="#b5bac1" FontSize="11" FontWeight="Medium"/>
                      <TextBlock Text="MediaFoundation / WidevineCdm / blob_storage / CacheStorage" Foreground="#4e5058" FontSize="10" Margin="0,3,0,0" TextWrapping="Wrap"/>
                    </StackPanel>
                  </StackPanel>
                </Border>
                <TextBlock Text="OPTIONAL" Foreground="#3d4045" FontSize="9"
                           FontFamily="Consolas" FontWeight="Bold" Margin="0,0,0,10"/>
                <Border CornerRadius="9" Background="#1e1f22" BorderBrush="#2e3035"
                        BorderThickness="1" Padding="14,11" Margin="0,0,0,20">
                  <Grid>
                    <CheckBox x:Name="ChkLocalStorage" Style="{StaticResource ModernCheck}" IsChecked="False">
                      <StackPanel>
                        <TextBlock Text="Remove Local Storage" Foreground="#dcddde" FontSize="11" FontWeight="Medium"/>
                        <TextBlock Text="You will need to sign in to Discord again after this" Foreground="#3d4045" FontSize="10" Margin="0,2,0,0"/>
                      </StackPanel>
                    </CheckBox>
                    <Border HorizontalAlignment="Right" VerticalAlignment="Center"
                            CornerRadius="4" Padding="6,2" Background="#1e1f22" BorderBrush="#3d4045" BorderThickness="1">
                      <TextBlock Text="logs you out" Foreground="#ed4245" FontSize="9" FontFamily="Consolas"/>
                    </Border>
                  </Grid>
                </Border>
              </StackPanel>
            </ScrollViewer>

            <ScrollViewer Grid.Row="1" x:Name="CaPage2Scroll" Visibility="Collapsed"
                          VerticalScrollBarVisibility="Auto" Padding="24,20,24,4">
              <StackPanel x:Name="CaPage2">
                <Grid Margin="0,0,0,8">
                  <TextBlock x:Name="CaProgressLabel" Text="Cleaning..."
                             Foreground="#4e5058" FontSize="9.5" FontFamily="Consolas"/>
                  <TextBlock x:Name="CaProgressPct" Text="0%"
                             Foreground="#4e5058" FontSize="9.5" FontFamily="Consolas" HorizontalAlignment="Right"/>
                </Grid>
                <Border Height="3" CornerRadius="2" Background="#111120" Margin="0,0,0,16">
                  <Grid>
                    <Border x:Name="CaProgressFill" HorizontalAlignment="Left" Width="0"
                            Background="#6b7280" CornerRadius="2"/>
                  </Grid>
                </Border>
                <ScrollViewer x:Name="CaLogScroll" VerticalScrollBarVisibility="Auto"
                              MaxHeight="220" Padding="0,0,4,0">
                  <StackPanel x:Name="CaLogPanel"/>
                </ScrollViewer>
              </StackPanel>
            </ScrollViewer>

            <Border Grid.Row="2" x:Name="CaFooter" BorderBrush="#2e3035"
                    BorderThickness="0,1,0,0" Padding="24,14" CornerRadius="0,0,16,16">
              <Grid>
                <StackPanel x:Name="CaBtnRunGroup" Orientation="Horizontal" HorizontalAlignment="Right">
                  <Button x:Name="BtnCaCancel" Content="Cancel"
                          Style="{StaticResource GhostBtn}" Height="34" Padding="18,0" Margin="0,0,8,0"/>
                  <Button x:Name="BtnCaRun" Content="Clean Now"
                          Style="{StaticResource PrimaryBtn}" Height="34" Padding="18,0"/>
                </StackPanel>
                <StackPanel x:Name="CaBtnRunningGroup" Orientation="Horizontal" HorizontalAlignment="Right"
                            Visibility="Collapsed">
                  <Button x:Name="BtnCaStop" Content="Stop"
                          Style="{StaticResource DangerBtn}" Height="34" Padding="18,0"/>
                </StackPanel>
                <StackPanel x:Name="CaBtnDoneGroup" Orientation="Horizontal" HorizontalAlignment="Right"
                            Visibility="Collapsed">
                  <Button x:Name="BtnCaReturn" Content="Return to menu"
                          Style="{StaticResource GhostBtn}" Height="34" Padding="18,0"/>
                </StackPanel>
              </Grid>
            </Border>
          </Grid>
        </Border>

        <!-- ADVANCED OPTIONS PANEL -->
        <Border x:Name="PanelAdvanced" Visibility="Collapsed"
                HorizontalAlignment="Center" VerticalAlignment="Center"
                Width="480" MaxHeight="560"
                Background="#18191c" BorderBrush="#2e3035" BorderThickness="1"
                CornerRadius="16">
          <Border.Effect>
            <DropShadowEffect Color="#000000" BlurRadius="60" ShadowDepth="0" Opacity="0.85"/>
          </Border.Effect>
          <Grid>
            <Grid.RowDefinitions>
              <RowDefinition Height="Auto"/>
              <RowDefinition Height="*"/>
              <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <Border Grid.Row="0" BorderBrush="#2e3035" BorderThickness="0,0,0,1"
                    Padding="24,20,24,16" CornerRadius="16,16,0,0">
              <Grid>
                <StackPanel Orientation="Horizontal">
                  <Border Width="36" Height="36" CornerRadius="10" Margin="0,0,12,0"
                          Background="#1e1f22" BorderBrush="#3d4045" BorderThickness="1">
                    <TextBlock Text="&#x2699;" FontSize="14" Foreground="#9ca3af"
                               HorizontalAlignment="Center" VerticalAlignment="Center"/>
                  </Border>
                  <StackPanel VerticalAlignment="Center">
                    <TextBlock Text="Advanced Options" Foreground="#e3e5e8" FontSize="14" FontWeight="SemiBold"/>
                    <TextBlock Text="Select what to keep or remove" Foreground="#4e5058" FontSize="10.5" Margin="0,3,0,0"/>
                  </StackPanel>
                </StackPanel>
                <Button x:Name="BtnCloseAdvanced" HorizontalAlignment="Right" VerticalAlignment="Center"
                        Style="{StaticResource ModalCloseBtn}" Content="x"/>
              </Grid>
            </Border>

            <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto" Padding="24,18,24,4">
              <StackPanel>
                <TextBlock Text="BACKUP" Foreground="#3d4045" FontSize="9"
                           FontFamily="Consolas" FontWeight="Bold" Margin="0,0,0,10"/>
                <Border CornerRadius="10" Background="#1e1f22" BorderBrush="#2e3035" BorderThickness="1" Margin="0,0,0,14">
                  <Grid Margin="14,11,14,11">
                    <CheckBox x:Name="ChkAdvBackup" Style="{StaticResource ModernCheck}" IsChecked="False">
                      <StackPanel>
                        <TextBlock Text="Create backup before debloating" Foreground="#dcddde" FontSize="11" FontWeight="Medium"/>
                        <TextBlock Text="Saves a full copy of Discord to your Desktop" Foreground="#3d4045" FontSize="10" Margin="0,2,0,0"/>
                      </StackPanel>
                    </CheckBox>
                    <Border HorizontalAlignment="Right" VerticalAlignment="Center"
                            CornerRadius="4" Padding="6,2" Background="#1a1a1e" BorderBrush="#2e3035" BorderThickness="1">
                      <TextBlock Text="optional" Foreground="#6b7280" FontSize="9" FontFamily="Consolas"/>
                    </Border>
                  </Grid>
                </Border>

                <TextBlock Text="MODULES" Foreground="#3d4045" FontSize="9"
                           FontFamily="Consolas" FontWeight="Bold" Margin="0,0,0,10"/>
                <Border CornerRadius="10" Background="#1e1f22" BorderBrush="#2e3035" BorderThickness="1" Margin="0,0,0,14">
                  <StackPanel>
                    <Grid Margin="14,12,14,12">
                      <CheckBox x:Name="ChkAdvKrisp" Style="{StaticResource ModernCheck}" IsChecked="False">
                        <StackPanel>
                          <TextBlock Text="Remove Krisp (noise suppression)" Foreground="#dcddde" FontSize="11" FontWeight="Medium"/>
                          <TextBlock Text="Only if you use another noise-cancellation solution" Foreground="#3d4045" FontSize="10" Margin="0,2,0,0"/>
                        </StackPanel>
                      </CheckBox>
                    </Grid>
                    <Border Background="#16171a" Height="1" Margin="14,0"/>
                    <Grid Margin="14,12,14,12">
                      <CheckBox x:Name="ChkAdvGameSDK" Style="{StaticResource ModernCheck}" IsChecked="True">
                        <StackPanel>
                          <TextBlock Text="Remove Game SDK DLLs" Foreground="#dcddde" FontSize="11" FontWeight="Medium"/>
                          <TextBlock Text="discord_game_sdk_*.dll - safe to remove for most users" Foreground="#3d4045" FontSize="10" Margin="0,2,0,0"/>
                        </StackPanel>
                      </CheckBox>
                      <Border HorizontalAlignment="Right" VerticalAlignment="Center"
                              CornerRadius="4" Padding="6,2" Background="#1e1f22" BorderBrush="#3d4045" BorderThickness="1">
                        <TextBlock Text="recommended" Foreground="#6b7280" FontSize="9" FontFamily="Consolas"/>
                      </Border>
                    </Grid>
                    <Border Background="#16171a" Height="1" Margin="14,0"/>
                    <StackPanel Margin="14,12,14,12">
                      <CheckBox x:Name="ChkAdvGamePresence" Style="{StaticResource ModernCheck}" IsChecked="False">
                        <StackPanel>
                          <TextBlock Text="Remove Game Presence / RPC" Foreground="#dcddde" FontSize="11" FontWeight="Medium"/>
                          <TextBlock Text="Disables game detection and rich presence broadcasting" Foreground="#3d4045" FontSize="10" Margin="0,2,0,0"/>
                        </StackPanel>
                      </CheckBox>
                      <Border CornerRadius="6" Background="#100e04" BorderBrush="#2a2000" BorderThickness="1"
                              Padding="10,7" Margin="0,8,0,0">
                        <TextBlock Foreground="#b08838" FontSize="9.5" TextWrapping="Wrap" LineHeight="16"
                                   Text="Warning: required by some games to link accounts (e.g. FiveM). Removing it may prevent joining certain servers."/>
                      </Border>
                    </StackPanel>
                  </StackPanel>
                </Border>

                <TextBlock Text="FILES AND COMPONENTS" Foreground="#3d4045" FontSize="9"
                           FontFamily="Consolas" FontWeight="Bold" Margin="0,0,0,10"/>
                <Border CornerRadius="10" Background="#1e1f22" BorderBrush="#2e3035" BorderThickness="1" Margin="0,0,0,14">
                  <StackPanel>
                    <Grid Margin="14,12,14,12">
                      <CheckBox x:Name="ChkAdvUpdater" Style="{StaticResource ModernCheck}" IsChecked="True">
                        <StackPanel>
                          <TextBlock Text="Remove auto-updater" Foreground="#dcddde" FontSize="11" FontWeight="Medium"/>
                          <TextBlock Text="Update.exe, SquirrelSetup, RELEASES package" Foreground="#3d4045" FontSize="10" Margin="0,2,0,0"/>
                        </StackPanel>
                      </CheckBox>
                      <Border HorizontalAlignment="Right" VerticalAlignment="Center"
                              CornerRadius="4" Padding="6,2" Background="#1e1f22" BorderBrush="#3d4045" BorderThickness="1">
                        <TextBlock Text="recommended" Foreground="#6b7280" FontSize="9" FontFamily="Consolas"/>
                      </Border>
                    </Grid>
                    <Border Background="#16171a" Height="1" Margin="14,0"/>
                    <Grid Margin="14,12,14,12">
                      <CheckBox x:Name="ChkAdvAutostart" Style="{StaticResource ModernCheck}" IsChecked="True">
                        <StackPanel>
                          <TextBlock Text="Disable autostart" Foreground="#dcddde" FontSize="11" FontWeight="Medium"/>
                          <TextBlock Text="Remove registry Run keys and scheduled tasks" Foreground="#3d4045" FontSize="10" Margin="0,2,0,0"/>
                        </StackPanel>
                      </CheckBox>
                      <Border HorizontalAlignment="Right" VerticalAlignment="Center"
                              CornerRadius="4" Padding="6,2" Background="#1e1f22" BorderBrush="#3d4045" BorderThickness="1">
                        <TextBlock Text="recommended" Foreground="#6b7280" FontSize="9" FontFamily="Consolas"/>
                      </Border>
                    </Grid>
                    <Border Background="#16171a" Height="1" Margin="14,0"/>
                    <Grid Margin="14,12,14,12">
                      <CheckBox x:Name="ChkAdvFSO" Style="{StaticResource ModernCheck}" IsChecked="True">
                        <StackPanel>
                          <TextBlock Text="Disable Fullscreen Optimization (FSO)" Foreground="#dcddde" FontSize="11" FontWeight="Medium"/>
                          <TextBlock Text="Prevents Windows from overriding exclusive fullscreen" Foreground="#3d4045" FontSize="10" Margin="0,2,0,0"/>
                        </StackPanel>
                      </CheckBox>
                    </Grid>
                    <Border Background="#16171a" Height="1" Margin="14,0"/>
                    <Grid Margin="14,12,14,12">
                      <CheckBox x:Name="ChkAdvJunk" Style="{StaticResource ModernCheck}" IsChecked="True">
                        <StackPanel>
                          <TextBlock Text="Remove junk files" Foreground="#dcddde" FontSize="11" FontWeight="Medium"/>
                          <TextBlock Text=".sig files, Vulkan DLLs, SwiftShader, d3dcompiler, etc." Foreground="#3d4045" FontSize="10" Margin="0,2,0,0"/>
                        </StackPanel>
                      </CheckBox>
                    </Grid>
                  </StackPanel>
                </Border>

              </StackPanel>
            </ScrollViewer>

            <Border Grid.Row="2" BorderBrush="#2e3035" BorderThickness="0,1,0,0"
                    Padding="24,14" CornerRadius="0,0,16,16">
              <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                <Button x:Name="BtnAdvCancel" Content="Cancel"
                        Style="{StaticResource GhostBtn}" Height="34" Padding="18,0" Margin="0,0,8,0"/>
                <Button x:Name="BtnAdvApply" Content="Apply &amp; Close"
                        Style="{StaticResource PrimaryBtn}" Height="34" Padding="18,0"/>
              </StackPanel>
            </Border>
          </Grid>
        </Border>

        <!-- SUCCESS OVERLAY -->
        <Border x:Name="SuccessOverlay" Visibility="Collapsed"
                HorizontalAlignment="Center" VerticalAlignment="Center"
                Width="260"
                Background="#0f1015" BorderBrush="#2e3035" BorderThickness="1"
                CornerRadius="20">
          <Border.Effect>
            <DropShadowEffect Color="#000000" BlurRadius="50" ShadowDepth="0" Opacity="0.95"/>
          </Border.Effect>
          <StackPanel HorizontalAlignment="Center" VerticalAlignment="Center" Margin="28,28,28,24">
            <Border Width="60" Height="60" CornerRadius="30" HorizontalAlignment="Center"
                    Background="#1e1f22" BorderBrush="#3d4045" BorderThickness="1.5"
                    Margin="0,0,0,18">
              <Border.Effect>
                <DropShadowEffect Color="#6b7280" BlurRadius="20" ShadowDepth="0" Opacity="0.3"/>
              </Border.Effect>
              <Canvas Width="26" Height="26" HorizontalAlignment="Center" VerticalAlignment="Center">
                <Polyline Points="4,14 11,20 22,7" Stroke="#9ca3af" StrokeThickness="2.5"
                          StrokeStartLineCap="Round" StrokeEndLineCap="Round" StrokeLineJoin="Round"/>
              </Canvas>
            </Border>
            <TextBlock x:Name="SuccessTitle" Text="Done"
                       Foreground="#e3e5e8" FontSize="17" FontWeight="SemiBold"
                       FontFamily="Segoe UI" HorizontalAlignment="Center"
                       Margin="0,0,0,8"/>
            <TextBlock x:Name="SuccessSubtitle" Text=""
                       Foreground="#5a6070" FontSize="10.5" FontFamily="Segoe UI"
                       HorizontalAlignment="Center" TextAlignment="Center"
                       TextWrapping="Wrap" MaxWidth="200"
                       LineHeight="17" Margin="0,0,0,20"/>
            <Button x:Name="BtnSuccessOk" Content="OK"
                    Style="{StaticResource SuccessOkBtn}"
                    Height="32" Width="100" Padding="0,0"/>
          </StackPanel>
        </Border>

      </Grid>
    </Grid>
  </Border>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)
$script:window = $window

function G($n){ $script:window.FindName($n) }

$TitleBar        = G "TitleBar"
$OuterBorder     = G "OuterBorder"
$BtnMin          = G "BtnMin"
$BtnMax          = G "BtnMax"
$BtnClose        = G "BtnClose"
$BtnConsole      = G "BtnConsole"
$BtnGithub       = G "BtnGithub"
$VersionBadge    = G "VersionBadge"
$UpdateBadge     = G "UpdateBadge"
$StatusDot       = G "StatusDot"
$ModalOverlay    = G "ModalOverlay"
$BtnOpenDebloat  = G "BtnOpenDebloat"
$BtnOpenSettings = G "BtnOpenSettings"
$BtnOpenCache    = G "BtnOpenCache"
$PanelDebloat      = G "PanelDebloat"
$BtnCloseDebloat   = G "BtnCloseDebloat"
$DbSelectedVariant = G "DbSelectedVariant"
$DbPage1           = G "DbPage1"
$DbPage1Scroll     = G "DbPage1Scroll"
$DbPage2           = G "DbPage2"
$DbPage2Scroll     = G "DbPage2Scroll"
$DbProgressLabel   = G "DbProgressLabel"
$DbProgressPct     = G "DbProgressPct"
$DbProgressFill    = G "DbProgressFill"
$DbLogPanel        = G "DbLogPanel"
$DbLogScroll       = G "DbLogScroll"
$DbFooter          = G "DbFooter"
$DbBtnRunGroup     = G "DbBtnRunGroup"
$DbBtnRunningGroup = G "DbBtnRunningGroup"
$DbBtnDoneGroup    = G "DbBtnDoneGroup"
$BtnDbStop         = G "BtnDbStop"
$BtnDbCancel       = G "BtnDbCancel"
$BtnDbRun          = G "BtnDbRun"
$BtnDbReturn       = G "BtnDbReturn"
$RdLangEN          = G "RdLangEN"
$RdLangFR          = G "RdLangFR"
$RdLangBoth        = G "RdLangBoth"
$PanelSettings    = G "PanelSettings"
$BtnCloseSettings = G "BtnCloseSettings"
$TabStPreview     = G "TabStPreview"
$TabStJson        = G "TabStJson"
$StPagePreview    = G "StPagePreview"
$StPageJson       = G "StPageJson"
$StJsonPath       = G "StJsonPath"
$StPage2          = G "StPage2"
$StProgressLabel  = G "StProgressLabel"
$StProgressPct    = G "StProgressPct"
$StProgressFill   = G "StProgressFill"
$StLogPanel       = G "StLogPanel"
$StLogScroll      = G "StLogScroll"
$StFooter         = G "StFooter"
$StBtnApplyGroup  = G "StBtnApplyGroup"
$StBtnDoneGroup   = G "StBtnDoneGroup"
$BtnStCancel      = G "BtnStCancel"
$BtnStApply       = G "BtnStApply"
$BtnStReturn      = G "BtnStReturn"
$PanelAdvanced       = G "PanelAdvanced"
$BtnOpenAdvanced     = G "BtnOpenAdvanced"
$BtnCloseAdvanced    = G "BtnCloseAdvanced"
$BtnAdvCancel        = G "BtnAdvCancel"
$BtnAdvApply         = G "BtnAdvApply"
$ChkAdvKrisp         = G "ChkAdvKrisp"
$ChkAdvGameSDK       = G "ChkAdvGameSDK"
$ChkAdvGamePresence  = G "ChkAdvGamePresence"
$ChkAdvUpdater       = G "ChkAdvUpdater"
$ChkAdvAutostart     = G "ChkAdvAutostart"
$ChkAdvFSO           = G "ChkAdvFSO"
$ChkAdvJunk          = G "ChkAdvJunk"
$ChkAdvBackup        = G "ChkAdvBackup"
$PanelCache        = G "PanelCache"
$BtnCloseCache     = G "BtnCloseCache"
$CaPage1           = G "CaPage1"
$CaPage1Scroll     = G "CaPage1Scroll"
$CaPage2           = G "CaPage2"
$CaPage2Scroll     = G "CaPage2Scroll"
$CaProgressLabel   = G "CaProgressLabel"
$CaProgressPct     = G "CaProgressPct"
$CaProgressFill    = G "CaProgressFill"
$CaLogPanel        = G "CaLogPanel"
$CaLogScroll       = G "CaLogScroll"
$CaFooter          = G "CaFooter"
$CaBtnRunGroup     = G "CaBtnRunGroup"
$CaBtnRunningGroup = G "CaBtnRunningGroup"
$CaBtnDoneGroup    = G "CaBtnDoneGroup"
$BtnCaStop         = G "BtnCaStop"
$BtnCaCancel       = G "BtnCaCancel"
$BtnCaRun          = G "BtnCaRun"
$BtnCaReturn       = G "BtnCaReturn"
$ChkLocalStorage   = G "ChkLocalStorage"
$SuccessOverlay  = G "SuccessOverlay"
$SuccessTitle    = G "SuccessTitle"
$SuccessSubtitle = G "SuccessSubtitle"
$BtnSuccessOk    = G "BtnSuccessOk"

$script:DbCts      = $null
$script:CaCts      = $null
$script:lastResult = @{ mb=""; items=0; cancelled=$false }

$TitleBar.Add_MouseLeftButtonDown({
    param($s,$e)
    if ($e.ClickCount -eq 2) {
        if ($script:window.WindowState -eq "Maximized") { $script:window.WindowState = "Normal" }
        else { $script:window.WindowState = "Maximized" }
    } else { $script:window.DragMove() }
})
$BtnMin.Add_Click({ $script:window.WindowState = "Minimized" })
$BtnMax.Add_Click({
    if ($script:window.WindowState -eq "Maximized") {
        $script:window.WindowState = "Normal"
        $OuterBorder.CornerRadius = "14"; $OuterBorder.Margin = "0"
    } else {
        $script:window.WindowState = "Maximized"
        $OuterBorder.CornerRadius = "0"; $OuterBorder.Margin = "0"
    }
})
$BtnClose.Add_Click({ $script:window.Close() })
$BtnGithub.Add_Click({ Start-Process "https://github.com/insovs/Discord-Optimization" })
# Load Win32 ShowWindow once at startup
Add-Type -Name Win32Console -Namespace "" -MemberDefinition '
    [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]   public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
' -EA SilentlyContinue

# Hide the existing console window on startup
$script:hConsole = [Win32Console]::GetConsoleWindow()
if ($script:hConsole -ne [IntPtr]::Zero) { [Win32Console]::ShowWindow($script:hConsole, 0) | Out-Null }
$script:ConsoleVisible = $false

$BtnConsole.Add_Click({
    if (-not $script:hConsole -or $script:hConsole -eq [IntPtr]::Zero) {
        $script:hConsole = [Win32Console]::GetConsoleWindow()
    }
    if ($script:ConsoleVisible) {
        [Win32Console]::ShowWindow($script:hConsole, 0) | Out-Null  # 0 = hide
        $script:ConsoleVisible = $false
        $BtnConsole.Foreground = [Windows.Media.BrushConverter]::new().ConvertFrom("#4e5058")
    } else {
        [Win32Console]::ShowWindow($script:hConsole, 5) | Out-Null  # 5 = show no activate
        $script:ConsoleVisible = $true
        $BtnConsole.Foreground = [Windows.Media.BrushConverter]::new().ConvertFrom("#9ca3af")
    }
})
$script:window.Add_StateChanged({
    if ($script:window.WindowState -eq "Maximized") {
        $OuterBorder.CornerRadius = "0"; $OuterBorder.Margin = "0"
    } else {
        $OuterBorder.CornerRadius = "14"; $OuterBorder.Margin = "8"
    }
})

function Br($h) { [Windows.Media.BrushConverter]::new().ConvertFrom($h) }


function Dismiss-SuccessOverlay {
    $SuccessOverlay.Visibility = "Collapsed"
    $ModalOverlay.Visibility   = "Collapsed"
}
$BtnSuccessOk.Add_Click({ Dismiss-SuccessOverlay })

function Show-SuccessOverlay {
    param([string]$title="Done",[string]$subtitle="")
    $SuccessTitle.Text    = $title
    $SuccessSubtitle.Text = $subtitle
    $PanelDebloat.Visibility  = "Collapsed"
    $PanelSettings.Visibility = "Collapsed"
    $PanelCache.Visibility    = "Collapsed"
    $PanelAdvanced.Visibility = "Collapsed"
    $ModalOverlay.Visibility  = "Visible"
    $SuccessOverlay.Visibility = "Visible"
}

function AddLog($panel, $scroll, $type, $msg) {
    $ts = (Get-Date).ToString("HH:mm:ss")
    switch ($type) {
        "ok"   { $dotColor="#9ca3af"; $tsColor="#353535"; $msgColor="#b5bac1"; $tagText="OK";  $tagBg="#1a1b1e"; $tagFg="#9ca3af"; $tagBd="#2e3035" }
        "warn" { $dotColor="#d4a017"; $tsColor="#3a2e10"; $msgColor="#b08838"; $tagText="WRN"; $tagBg="#100e04"; $tagFg="#907020"; $tagBd="#1e1800" }
        "err"  { $dotColor="#ed4245"; $tsColor="#3a1818"; $msgColor="#c06060"; $tagText="ERR"; $tagBg="#100808"; $tagFg="#a03030"; $tagBd="#1e0e0e" }
        default{ $dotColor="#6b7280"; $tsColor="#2a2a2a"; $msgColor="#6b7280"; $tagText="INF"; $tagBg="#1e1f22"; $tagFg="#6b7280"; $tagBd="#2e3035" }
    }
    $ts_c=$ts; $dot_c=$dotColor; $tsc_c=$tsColor; $msg_c=$msgColor
    $tagt_c=$tagText; $tagb_c=$tagBg; $tagf_c=$tagFg; $tagd_c=$tagBd
    $m_c=$msg; $p_c=$panel; $s_c=$scroll
    $script:window.Dispatcher.Invoke([action]{
        $row = New-Object Windows.Controls.Border
        $row.Padding         = New-Object Windows.Thickness 12,6,8,6
        $row.Margin          = New-Object Windows.Thickness 0,0,0,1
        $row.BorderThickness = New-Object Windows.Thickness 2,0,0,0
        $row.BorderBrush     = Br $dot_c
        $row.CornerRadius    = New-Object Windows.CornerRadius 0,5,5,0
        $dock = New-Object Windows.Controls.DockPanel
        $dock.LastChildFill = $true
        $tagBorder = New-Object Windows.Controls.Border
        $tagBorder.CornerRadius    = New-Object Windows.CornerRadius 4
        $tagBorder.Background      = Br $tagb_c
        $tagBorder.BorderBrush     = Br $tagd_c
        $tagBorder.BorderThickness = New-Object Windows.Thickness 1
        $tagBorder.Padding         = New-Object Windows.Thickness 6,2,6,2
        $tagBorder.Margin          = New-Object Windows.Thickness 0,0,10,0
        $tagBorder.VerticalAlignment = "Center"
        [Windows.Controls.DockPanel]::SetDock($tagBorder, "Left")
        $tagTb = New-Object Windows.Controls.TextBlock
        $tagTb.Text = $tagt_c; $tagTb.Foreground = Br $tagf_c
        $tagTb.FontFamily = New-Object Windows.Media.FontFamily "Segoe UI"
        $tagTb.FontSize = 9; $tagTb.FontWeight = [Windows.FontWeights]::SemiBold
        $tagBorder.Child = $tagTb
        $tsTb = New-Object Windows.Controls.TextBlock
        $tsTb.Text = $ts_c; $tsTb.Foreground = Br $tsc_c
        $tsTb.FontFamily = New-Object Windows.Media.FontFamily "Segoe UI"
        $tsTb.FontSize = 9.5; $tsTb.Margin = New-Object Windows.Thickness 0,0,14,0
        $tsTb.VerticalAlignment = "Center"
        [Windows.Controls.DockPanel]::SetDock($tsTb, "Left")
        $msgTb = New-Object Windows.Controls.TextBlock
        $msgTb.Text = $m_c; $msgTb.Foreground = Br $msg_c
        $msgTb.FontFamily = New-Object Windows.Media.FontFamily "Segoe UI"
        $msgTb.FontSize = 10; $msgTb.TextWrapping = "Wrap"
        $msgTb.VerticalAlignment = "Center"
        $dock.Children.Add($tagBorder) | Out-Null
        $dock.Children.Add($tsTb)      | Out-Null
        $dock.Children.Add($msgTb)     | Out-Null
        $row.Child = $dock
        $p_c.Children.Add($row) | Out-Null
        $s_c.ScrollToBottom()
    })
    Dispatch
}

function OpenPanel($p)  { $ModalOverlay.Visibility = "Visible";   $p.Visibility = "Visible"   }
function ClosePanel($p) { $p.Visibility = "Collapsed"; $ModalOverlay.Visibility = "Collapsed" }

function Get-SelectedVariant { return $DISCORD_VARIANTS[0] }

$script:RunspaceAddLogSB = {
    param([string]$rs_type,[string]$rs_msg,[object]$rs_panel_p,[object]$rs_scroll_p,[object]$rs_window_p)
    $ts=(Get-Date).ToString("HH:mm:ss")
    switch ($rs_type) {
        "ok"   { $dot="#9ca3af"; $tsc="#353535"; $mc="#b5bac1"; $tt="OK";  $tb="#1a1b1e"; $tf="#9ca3af"; $td="#2e3035" }
        "warn" { $dot="#d4a017"; $tsc="#3a2e10"; $mc="#b08838"; $tt="WRN"; $tb="#100e04"; $tf="#907020"; $td="#1e1800" }
        "err"  { $dot="#ed4245"; $tsc="#3a1818"; $mc="#c06060"; $tt="ERR"; $tb="#100808"; $tf="#a03030"; $td="#1e0e0e" }
        default{ $dot="#6b7280"; $tsc="#2a2a2a"; $mc="#6b7280"; $tt="INF"; $tb="#1e1f22"; $tf="#6b7280"; $td="#2e3035" }
    }
    $l_ts=$ts; $l_dot=$dot; $l_tsc=$tsc; $l_mc=$mc; $l_tt=$tt
    $l_tb=$tb; $l_tf=$tf; $l_td=$td; $l_msg=$rs_msg; $l_panel=$rs_panel_p; $l_scroll=$rs_scroll_p
    $rs_window_p.Dispatcher.Invoke([action]{
        $conv=[Windows.Media.BrushConverter]::new()
        $brDot=$conv.ConvertFrom($l_dot); $brTsc=$conv.ConvertFrom($l_tsc); $brMc=$conv.ConvertFrom($l_mc)
        $brTb=$conv.ConvertFrom($l_tb);   $brTf=$conv.ConvertFrom($l_tf);   $brTd=$conv.ConvertFrom($l_td)
        $row=New-Object Windows.Controls.Border
        $row.Padding=$([Windows.Thickness]::new(12,6,8,6)); $row.Margin=$([Windows.Thickness]::new(0,0,0,1))
        $row.BorderThickness=$([Windows.Thickness]::new(2,0,0,0)); $row.BorderBrush=$brDot
        $row.CornerRadius=$([Windows.CornerRadius]::new(0,5,5,0))
        $dock=New-Object Windows.Controls.DockPanel; $dock.LastChildFill=$true
        $tagB=New-Object Windows.Controls.Border; $tagB.CornerRadius=$([Windows.CornerRadius]::new(4))
        $tagB.Background=$brTb; $tagB.BorderBrush=$brTd; $tagB.BorderThickness=$([Windows.Thickness]::new(1))
        $tagB.Padding=$([Windows.Thickness]::new(6,2,6,2)); $tagB.Margin=$([Windows.Thickness]::new(0,0,10,0))
        $tagB.VerticalAlignment="Center"
        [Windows.Controls.DockPanel]::SetDock($tagB,"Left")
        $tagTb=New-Object Windows.Controls.TextBlock; $tagTb.Text=$l_tt; $tagTb.Foreground=$brTf
        $tagTb.FontFamily=New-Object Windows.Media.FontFamily "Segoe UI"; $tagTb.FontSize=9
        $tagTb.FontWeight=[Windows.FontWeights]::SemiBold; $tagB.Child=$tagTb
        $tsTb=New-Object Windows.Controls.TextBlock; $tsTb.Text=$l_ts; $tsTb.Foreground=$brTsc
        $tsTb.FontFamily=New-Object Windows.Media.FontFamily "Segoe UI"; $tsTb.FontSize=9.5
        $tsTb.Margin=$([Windows.Thickness]::new(0,0,14,0)); $tsTb.VerticalAlignment="Center"
        [Windows.Controls.DockPanel]::SetDock($tsTb,"Left")
        $mTb=New-Object Windows.Controls.TextBlock; $mTb.Text=$l_msg; $mTb.Foreground=$brMc
        $mTb.FontFamily=New-Object Windows.Media.FontFamily "Segoe UI"; $mTb.FontSize=10
        $mTb.TextWrapping="Wrap"; $mTb.VerticalAlignment="Center"
        $dock.Children.Add($tagB)|Out-Null; $dock.Children.Add($tsTb)|Out-Null; $dock.Children.Add($mTb)|Out-Null
        $row.Child=$dock; $l_panel.Children.Add($row)|Out-Null; $l_scroll.ScrollToBottom()
    })
}

function Watch-RunspaceCompletion($ps_ref, $rs_ref, $handle_ref) {
    $timer = New-Object Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromMilliseconds(400)
    $ps_local=$ps_ref; $rs_local=$rs_ref; $h_local=$handle_ref
    $timer.Add_Tick({
        param($sender,$e)
        if ($h_local.IsCompleted) {
            $sender.Stop()
            try { $ps_local.EndInvoke($h_local) } catch {}
            $ps_local.Dispose(); $rs_local.Dispose()
            try { if ($script:DbCts) { $script:DbCts.Dispose(); $script:DbCts=$null } } catch {}
            try { if ($script:CaCts) { $script:CaCts.Dispose(); $script:CaCts=$null } } catch {}
        }
    })
    $timer.Start()
}

function Start-UpdateCheck {
    $job = Start-Job -ScriptBlock {
        param($url,$cur)
        try {
            $latest=(Invoke-WebRequest $url -UseBasicParsing -TimeoutSec 4 -EA Stop).Content.Trim()
            if ([version]$latest -gt [version]$cur) { return $latest }
        } catch {}
        return $null
    } -ArgumentList $UPDATE_URL,$TOOL_VERSION
    $timer=New-Object Windows.Threading.DispatcherTimer; $timer.Interval=[TimeSpan]::FromMilliseconds(500)
    $timer.Add_Tick({
        param($sender,$e)
        if ($job.State -eq "Completed") {
            $sender.Stop(); $result=Receive-Job $job -EA SilentlyContinue; Remove-Job $job -Force -EA SilentlyContinue
            if ($result) { $UpdateBadge.Text="  update v$result available"; $UpdateBadge.Visibility="Visible" }
        } elseif ($job.State -eq "Failed") { $sender.Stop(); Remove-Job $job -Force -EA SilentlyContinue }
    })
    $timer.Start()
}


$TabStPreview.Add_Click({
    $StPagePreview.Visibility="Visible"; $StPageJson.Visibility="Collapsed"
    $TabStPreview.BorderBrush=Br "#6b7280"; $TabStPreview.Foreground=Br "#9ca3af"
    $TabStJson.BorderBrush=Br "Transparent"; $TabStJson.Foreground=Br "#4e5058"
})
$TabStJson.Add_Click({
    $StPagePreview.Visibility="Collapsed"; $StPageJson.Visibility="Visible"
    $TabStJson.BorderBrush=Br "#6b7280"; $TabStJson.Foreground=Br "#9ca3af"
    $TabStPreview.BorderBrush=Br "Transparent"; $TabStPreview.Foreground=Br "#4e5058"
})

function Apply-Prefs {
    $ChkLocalStorage.IsChecked = [bool]$prefs.localStorage
    switch ($prefs.lang) { "fr" { $RdLangFR.IsChecked=$true } "both" { $RdLangBoth.IsChecked=$true } default { $RdLangEN.IsChecked=$true } }
}

$BtnOpenDebloat.Add_Click({
    $variant=Get-SelectedVariant
    $DbLogPanel.Children.Clear()
    $DbPage1Scroll.Visibility="Visible"; $DbPage2Scroll.Visibility="Collapsed"
    $DbBtnRunGroup.Visibility="Visible"; $DbBtnRunningGroup.Visibility="Collapsed"; $DbBtnDoneGroup.Visibility="Collapsed"
    $BtnOpenAdvanced.Visibility="Visible"
    OpenPanel $PanelDebloat
})
$BtnCloseDebloat.Add_Click({ ClosePanel $PanelDebloat })
$BtnDbCancel.Add_Click({    ClosePanel $PanelDebloat })
$BtnDbReturn.Add_Click({
    if (-not $script:lastResult.cancelled) {
        $PanelDebloat.Visibility="Collapsed"
        Show-SuccessOverlay -title "Debloat complete" -subtitle "$($script:lastResult.mb) freed. Restart Discord to apply changes."
    } else { ClosePanel $PanelDebloat }
})
$BtnDbStop.Add_Click({
    if ($script:DbCts) { $script:DbCts.Cancel() }
    AddLog $DbLogPanel $DbLogScroll "warn" "Stop requested by user..."
    $BtnDbStop.IsEnabled=$false
})
$BtnOpenAdvanced.Add_Click({
    $PanelDebloat.Visibility="Collapsed"
    $PanelAdvanced.Visibility="Visible"
})
$BtnCloseAdvanced.Add_Click({ $PanelAdvanced.Visibility="Collapsed"; $PanelDebloat.Visibility="Visible" })
$BtnAdvCancel.Add_Click({    $PanelAdvanced.Visibility="Collapsed"; $PanelDebloat.Visibility="Visible" })
$BtnAdvApply.Add_Click({
    $PanelAdvanced.Visibility="Collapsed"; $PanelDebloat.Visibility="Visible"
})
$BtnOpenSettings.Add_Click({
    $variant=Get-SelectedVariant; $StJsonPath.Text="$($variant.AppData)\settings.json"
    $StLogPanel.Children.Clear()
    $StPagePreview.Visibility="Visible"; $StPageJson.Visibility="Collapsed"; $StPage2.Visibility="Collapsed"
    $StBtnApplyGroup.Visibility="Visible"; $StBtnDoneGroup.Visibility="Collapsed"
    OpenPanel $PanelSettings
})
$BtnCloseSettings.Add_Click({ ClosePanel $PanelSettings })
$BtnStCancel.Add_Click({     ClosePanel $PanelSettings })
$BtnStReturn.Add_Click({
    if (-not $script:lastResult.cancelled) {
        $PanelSettings.Visibility="Collapsed"
        Show-SuccessOverlay -title "Settings applied" -subtitle "Hardware acceleration disabled, auto-updates blocked. Restart Discord."
    } else { ClosePanel $PanelSettings }
})
$BtnOpenCache.Add_Click({
    $CaLogPanel.Children.Clear()
    $CaPage1Scroll.Visibility="Visible"; $CaPage2Scroll.Visibility="Collapsed"
    $CaBtnRunGroup.Visibility="Visible"; $CaBtnRunningGroup.Visibility="Collapsed"; $CaBtnDoneGroup.Visibility="Collapsed"
    OpenPanel $PanelCache
})
$BtnCloseCache.Add_Click({ ClosePanel $PanelCache })
$BtnCaCancel.Add_Click({   ClosePanel $PanelCache })
$BtnCaReturn.Add_Click({
    if (-not $script:lastResult.cancelled) {
        $PanelCache.Visibility="Collapsed"
        Show-SuccessOverlay -title "Cache cleared" -subtitle "$($script:lastResult.mb) removed. Discord should start faster."
    } else { ClosePanel $PanelCache }
})
$BtnCaStop.Add_Click({
    if ($script:CaCts) { $script:CaCts.Cancel() }
    AddLog $CaLogPanel $CaLogScroll "warn" "Stop requested by user..."
    $BtnCaStop.IsEnabled=$false
})

# =============================================================================
# DEBLOAT OPERATION
# =============================================================================
$BtnDbRun.Add_Click({
    $doBackup=$ChkAdvBackup.IsChecked; $doKrisp=$ChkAdvKrisp.IsChecked
    $doGameSDK=$ChkAdvGameSDK.IsChecked; $doGamePresence=$ChkAdvGamePresence.IsChecked
    $doUpdater=$ChkAdvUpdater.IsChecked; $doAutostart=$ChkAdvAutostart.IsChecked
    $doFSO=$ChkAdvFSO.IsChecked; $doJunk=$ChkAdvJunk.IsChecked
    $lang=if ($RdLangFR.IsChecked) {"fr"} elseif ($RdLangBoth.IsChecked) {"both"} else {"en"}
    $variant=Get-SelectedVariant
    $prefs.lang=$lang
    Save-Prefs $prefs
    $script:lastResult = @{ mb=""; items=0; cancelled=$false }
    $DbPage1Scroll.Visibility="Collapsed"; $DbPage2Scroll.Visibility="Visible"
    $DbBtnRunGroup.Visibility="Collapsed"; $DbBtnRunningGroup.Visibility="Visible"; $DbBtnDoneGroup.Visibility="Collapsed"
    $BtnOpenAdvanced.Visibility="Collapsed"
    $BtnDbStop.IsEnabled=$true
    $script:DbCts=[System.Threading.CancellationTokenSource]::new()
    $token=$script:DbCts.Token
    $rs=[runspacefactory]::CreateRunspace(); $rs.ApartmentState="STA"; $rs.ThreadOptions="ReuseThread"; $rs.Open()
    $rs.SessionStateProxy.SetVariable("rs_window",$script:window)
    $rs.SessionStateProxy.SetVariable("rs_panel",$DbLogPanel)
    $rs.SessionStateProxy.SetVariable("rs_scroll",$DbLogScroll)
    $rs.SessionStateProxy.SetVariable("rs_fill",$DbProgressFill)
    $rs.SessionStateProxy.SetVariable("rs_pct",$DbProgressPct)
    $rs.SessionStateProxy.SetVariable("rs_label",$DbProgressLabel)
    $rs.SessionStateProxy.SetVariable("rs_token",$token)
    $rs.SessionStateProxy.SetVariable("rs_discordPath",$variant.Path)
    $rs.SessionStateProxy.SetVariable("rs_variantName",$variant.Name)
    $rs.SessionStateProxy.SetVariable("rs_doBackup",$doBackup)
    $rs.SessionStateProxy.SetVariable("rs_doKrisp",$doKrisp)
    $rs.SessionStateProxy.SetVariable("rs_doGameSDK",$doGameSDK)
    $rs.SessionStateProxy.SetVariable("rs_doGamePresence",$doGamePresence)
    $rs.SessionStateProxy.SetVariable("rs_doUpdater",$doUpdater)
    $rs.SessionStateProxy.SetVariable("rs_doAutostart",$doAutostart)
    $rs.SessionStateProxy.SetVariable("rs_doFSO",$doFSO)
    $rs.SessionStateProxy.SetVariable("rs_doJunk",$doJunk)
    $rs.SessionStateProxy.SetVariable("rs_lang",$lang)
    $rs.SessionStateProxy.SetVariable("RunspaceAddLogSB",$script:RunspaceAddLogSB)
    $ps=[powershell]::Create(); $ps.Runspace=$rs
    $ps.AddScript({
        function AddLog([string]$type,[string]$msg) { & $RunspaceAddLogSB -rs_type $type -rs_msg $msg -rs_panel_p $rs_panel -rs_scroll_p $rs_scroll -rs_window_p $rs_window }
        function SetProg([int]$v) {
            $rs_window.Dispatcher.Invoke([action]{
                $maxW=[math]::Max(100,$rs_fill.Parent.ActualWidth)
                $rs_fill.Width=[math]::Max(0,[math]::Min($maxW,$maxW*$v/100)); $rs_pct.Text="$v%"
            })
        }
        function SetLabel([string]$t,[string]$fg="") {
            $lt=$t; $lf=$fg
            $rs_window.Dispatcher.Invoke([action]{
                $rs_label.Text=$lt
                if ($lf -ne "") { $rs_label.Foreground=[Windows.Media.BrushConverter]::new().ConvertFrom($lf) }
            })
        }
        function Get-FolderSize($path) {
            if (-not (Test-Path $path)) { return 0 }
            try { (Get-ChildItem $path -Recurse -Force -EA SilentlyContinue|Measure-Object -Property Length -Sum -EA SilentlyContinue).Sum } catch { 0 }
        }
        function Format-MB($b) { "$([math]::Round($b/1MB,2)) MB" }
        function Safe-Remove($path,[ref]$bytesRef) {
            if (-not (Test-Path $path)) { return $false }
            $size=Get-FolderSize $path
            Remove-Item $path -Recurse -Force -EA SilentlyContinue; $bytesRef.Value+=$size; return $true
        }
        function Safe-RemoveItem($path,[ref]$bytesRef) {
            if (-not (Test-Path $path)) { return $false }
            try { $size=(Get-Item $path -EA SilentlyContinue).Length } catch { $size=0 }
            Remove-Item $path -Force -EA SilentlyContinue; $bytesRef.Value+=$size; return $true
        }
        function CheckCancelled {
            if ($rs_token.IsCancellationRequested) { AddLog "warn" "Operation cancelled"; return $true }
            return $false
        }
        $sw=[System.Diagnostics.Stopwatch]::StartNew(); $totalBytes=[ref]0L; $totalFiles=0; $errorCount=0; $cancelled=$false
        if (-not (Test-Path $rs_discordPath)) { AddLog "err" "Installation not found: $rs_discordPath"; SetLabel "Not found" "#ed4245"; return }
        $highest=[System.Version]"0.0.0"; $activeDir=""
        Get-ChildItem "$rs_discordPath\app-*" -Directory -EA SilentlyContinue|ForEach-Object {
            try { $v=[System.Version]($_.Name.Substring(4)); if ($v -gt $highest) { $highest=$v; $activeDir=$_.FullName } } catch {}
        }
        if (-not $activeDir) { AddLog "err" "No valid version folder found"; SetLabel "Error" "#ed4245"; return }
        AddLog "info" "Target: $rs_variantName  v$highest"
        SetLabel "Closing $rs_variantName..."; SetProg 4
        $procs=Get-Process|Where-Object { try { $_.Path -like "$rs_discordPath*" } catch { $false } }
        if (-not $procs) { $procs=Get-Process -Name "discord" -EA SilentlyContinue }
        if ($procs) { $procs|Stop-Process -Force -EA SilentlyContinue; Start-Sleep -Milliseconds 800; AddLog "ok" "$($procs.Count) process(es) closed" }
        else { AddLog "info" "Discord not running" }
        if (CheckCancelled) { $cancelled=$true }
        if (-not $cancelled -and $rs_doBackup) {
            SetLabel "Creating backup..."; SetProg 10
            $bp="$([Environment]::GetFolderPath('Desktop'))\Discord_Backup_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss')"
            try { Copy-Item $rs_discordPath $bp -Recurse -Force -EA Stop; AddLog "ok" "Backup saved: $bp" } catch { AddLog "err" "Backup failed: $($_.Exception.Message)"; $errorCount++ }
            if (CheckCancelled) { $cancelled=$true }
        }
        if (-not $cancelled) {
            SetLabel "Removing old versions..."; SetProg 22
            $old=Get-ChildItem "$rs_discordPath\app-*" -Directory|Where-Object { $_.FullName -ne $activeDir }
            $c=0
            foreach ($d in $old) { if (CheckCancelled) { $cancelled=$true; break }; if (Safe-Remove $d.FullName ([ref]$totalBytes)) { $c++ } }
            if ($c -gt 0) { AddLog "ok" "Old versions removed: $c - $(Format-MB $totalBytes.Value) freed so far" } else { AddLog "info" "No old versions found" }
        }
        if (-not $cancelled) {
            SetLabel "Removing unused modules..."; SetProg 38
            $modPath="$activeDir\modules"
            if (Test-Path $modPath) {
                $keep=@("discord_desktop_core-1","discord_modules-1","discord_utils-1","discord_voice-1")
                if (-not $rs_doKrisp) { $keep+="discord_krisp-1" }
                $sdkRemoved=0
                if ($rs_doGameSDK) {
                    Get-ChildItem "$modPath\discord_modules-1" -Recurse -Filter "discord_game_sdk_*.dll" -EA SilentlyContinue|
                        ForEach-Object { Safe-RemoveItem $_.FullName ([ref]$totalBytes)|Out-Null; $sdkRemoved++ }
                }
                if ($rs_doGamePresence) { $keep=$keep|Where-Object { $_ -notmatch "game_presence|rpc" } }
                $n=0; $beforeMod=Get-FolderSize $modPath
                Get-ChildItem $modPath -Directory|Where-Object { $keep -notcontains $_.Name }|ForEach-Object {
                    if (CheckCancelled) { $cancelled=$true; return }
                    if (Safe-Remove $_.FullName ([ref]$totalBytes)) { $n++ }
                }
                $freedMod=Format-MB ($beforeMod-(Get-FolderSize $modPath))
                AddLog "ok" "Modules: $n removed | $sdkRemoved SDK DLLs | $freedMod freed"; $totalFiles+=$n+$sdkRemoved
            } else { AddLog "warn" "Modules folder not found" }
        }
        if (-not $cancelled) {
            SetLabel "Removing language packs..."; SetProg 52
            $localePath="$activeDir\locales"
            if (Test-Path $localePath) {
                $keep=switch ($rs_lang) { "en" {@("en-US.pak")} "fr" {@("fr.pak")} "both" {@("en-US.pak","fr.pak")} }
                $n=0; $beforeLang=Get-FolderSize $localePath
                Get-ChildItem "$localePath\*.pak"|Where-Object { $keep -notcontains $_.Name }|ForEach-Object {
                    if (CheckCancelled) { $cancelled=$true; return }
                    if (Safe-RemoveItem $_.FullName ([ref]$totalBytes)) { $n++ }
                }
                $freedLang=Format-MB ($beforeLang-(Get-FolderSize $localePath))
                AddLog "ok" "Lang packs: $n removed | kept $($keep -join ', ') | $freedLang freed"; $totalFiles+=$n
            } else { AddLog "warn" "Locales folder not found" }
        }
        if (-not $cancelled -and $rs_doJunk) {
            SetLabel "Cleaning junk files..."; SetProg 62
            @("$activeDir\*.log","$rs_discordPath\*.log")|ForEach-Object { Remove-Item $_ -Force -EA SilentlyContinue }
            $junk=@("$activeDir\.first-run","$activeDir\Discord.exe.sig","$activeDir\discord_wer.*","$activeDir\vk_swiftshader*.*","$activeDir\vulkan-1.*","$activeDir\Microsoft.Gaming.XboxApp.XboxNetwork.winmd","$activeDir\d3dcompiler*.*","$activeDir\libGLESv2.dll","$activeDir\libEGL.dll","$activeDir\chrome_200_percent.pak")
            $n=0
            foreach ($j in $junk) { if (CheckCancelled) { $cancelled=$true; break }; if (Test-Path $j) { Safe-RemoveItem $j ([ref]$totalBytes)|Out-Null; $n++ } }
            AddLog "ok" "Junk files: $n removed"; $totalFiles+=$n
        }
        if (-not $cancelled -and $rs_doAutostart) {
            SetLabel "Disabling autostart..."; SetProg 72
            $hits=0
            $runKeys=@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run","HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run","HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce")
            foreach ($rk in $runKeys) {
                if (Test-Path $rk) {
                    (Get-ItemProperty $rk -EA SilentlyContinue).PSObject.Properties|Where-Object { $_.Value -like "*discord*" }|ForEach-Object {
                        Remove-ItemProperty -Path $rk -Name $_.Name -Force -EA SilentlyContinue; $hits++
                    }
                }
            }
            $tasks=Get-ScheduledTask -EA SilentlyContinue|Where-Object { $_.TaskName -like "*discord*" }
            if ($tasks) { $tasks|ForEach-Object { Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -EA SilentlyContinue|Out-Null; $hits++ } }
            if ($hits -gt 0) { AddLog "ok" "Autostart: $hits entr(y/ies) removed" } else { AddLog "info" "No autostart entries found" }
        }
        if (-not $cancelled -and $rs_doFSO) {
            SetLabel "Disabling FSO..."; SetProg 80
            $fsoApps=@(); if ($activeDir -and (Test-Path "$activeDir\Discord.exe")) { $fsoApps+="$activeDir\Discord.exe" }
            $fsoRoot="HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
            if (-not (Test-Path $fsoRoot)) { New-Item -Path $fsoRoot -Force|Out-Null }
            $fsoOk=0
            foreach ($exe in $fsoApps) {
                try { Set-ItemProperty -Path $fsoRoot -Name $exe -Value "~ DISABLEDXMAXIMIZEDWINDOWEDMODE" -Force -EA Stop; $fsoOk++ } catch { AddLog "warn" "FSO write failed: $(Split-Path $exe -Leaf)"; $errorCount++ }
            }
            AddLog "ok" "FSO disabled: $fsoOk executable(s)"
        }
        if (-not $cancelled -and $rs_doUpdater) {
            SetLabel "Removing auto-updater..."; SetProg 88
            foreach ($p in @("$rs_discordPath\Update.exe","$rs_discordPath\SquirrelSetup*","$rs_discordPath\Discord_updater*")) { Safe-RemoveItem $p ([ref]$totalBytes)|Out-Null }
            $pkgPath="$rs_discordPath\Packages"
            if (Test-Path $pkgPath) { Get-ChildItem $pkgPath|Where-Object { $_.Name -ne "RELEASES" }|ForEach-Object { Safe-Remove $_.FullName ([ref]$totalBytes)|Out-Null } }
            Remove-Item "$([Environment]::GetFolderPath('Desktop'))\Discord.lnk" -Force -EA SilentlyContinue
            Remove-Item "$([Environment]::GetFolderPath('Desktop'))\Discord Debloated.lnk" -Force -EA SilentlyContinue
            try {
                $wsh=New-Object -ComObject WScript.Shell; $sc=$wsh.CreateShortcut("$([Environment]::GetFolderPath('Desktop'))\Discord Debloated.lnk")
                $sc.TargetPath="$activeDir\Discord.exe"; $sc.Save(); AddLog "ok" "Auto-updater removed | shortcut created on Desktop"
            } catch { AddLog "ok" "Auto-updater removed"; AddLog "warn" "Shortcut creation failed: $($_.Exception.Message)"; $errorCount++ }
        }
        $sw.Stop(); SetProg 100
        if ($cancelled) { SetLabel "Cancelled" "#ed4245"; AddLog "warn" "Cancelled after $([int]$sw.Elapsed.TotalSeconds)s" }
        else {
            AddLog "ok" "Done in $([int]$sw.Elapsed.TotalSeconds)s - $totalFiles items, $(Format-MB $totalBytes.Value) freed, $errorCount error(s)."
            AddLog "ok" "Restart Discord to apply all changes."
            SetLabel "Completed!" "#9ca3af"
        }
        $lMb=$null; $lCan=$cancelled; $lMb=Format-MB $totalBytes.Value
        $rs_window.Dispatcher.Invoke([action]{
            $script:lastResult = @{ mb=$lMb; items=$totalFiles; cancelled=$lCan }
            $r1=$rs_window.FindName("DbBtnRunningGroup"); $r2=$rs_window.FindName("DbBtnDoneGroup")
            if ($r1) { $r1.Visibility="Collapsed" }; if ($r2) { $r2.Visibility="Visible" }
        })
    })|Out-Null
    $handle=$ps.BeginInvoke(); Watch-RunspaceCompletion $ps $rs $handle
})

# =============================================================================
# SETTINGS OPERATION
# =============================================================================
$BtnStApply.Add_Click({
    $variant=Get-SelectedVariant
    $script:lastResult = @{ mb=""; items=0; cancelled=$false }
    $StBtnApplyGroup.Visibility="Collapsed"; $StBtnDoneGroup.Visibility="Collapsed"
    $StPagePreview.Visibility="Collapsed"; $StPageJson.Visibility="Collapsed"; $StPage2.Visibility="Visible"
    $rs=[runspacefactory]::CreateRunspace(); $rs.ApartmentState="STA"; $rs.ThreadOptions="ReuseThread"; $rs.Open()
    $rs.SessionStateProxy.SetVariable("rs_window",$script:window)
    $rs.SessionStateProxy.SetVariable("rs_panel",$StLogPanel); $rs.SessionStateProxy.SetVariable("rs_scroll",$StLogScroll)
    $rs.SessionStateProxy.SetVariable("rs_fill",$StProgressFill); $rs.SessionStateProxy.SetVariable("rs_pct",$StProgressPct)
    $rs.SessionStateProxy.SetVariable("rs_label",$StProgressLabel)
    $rs.SessionStateProxy.SetVariable("rs_sf","$($variant.AppData)\settings.json")
    $rs.SessionStateProxy.SetVariable("rs_varName",$variant.Name)
    $rs.SessionStateProxy.SetVariable("RunspaceAddLogSB",$script:RunspaceAddLogSB)
    $ps=[powershell]::Create(); $ps.Runspace=$rs
    $ps.AddScript({
        function AddLog([string]$type,[string]$msg) { & $RunspaceAddLogSB -rs_type $type -rs_msg $msg -rs_panel_p $rs_panel -rs_scroll_p $rs_scroll -rs_window_p $rs_window }
        function SetProg([int]$v) {
            $rs_window.Dispatcher.Invoke([action]{
                $maxW=[math]::Max(100,$rs_fill.Parent.ActualWidth)
                $rs_fill.Width=[math]::Max(0,[math]::Min($maxW,$maxW*$v/100)); $rs_pct.Text="$v%"
            })
        }
        function SetLabel([string]$t,[string]$fg="") {
            $lt=$t; $lf=$fg
            $rs_window.Dispatcher.Invoke([action]{
                $rs_label.Text=$lt
                if ($lf -ne "") { $rs_label.Foreground=[Windows.Media.BrushConverter]::new().ConvertFrom($lf) }
            })
        }
        $rs_sfDir = Split-Path $rs_sf -Parent
        if (-not (Test-Path $rs_sfDir)) {
            AddLog "err" "AppData folder not found: $rs_sfDir"
            $rs_window.Dispatcher.Invoke([action]{ $rs_window.FindName("StBtnDoneGroup").Visibility="Visible" }); return
        }
        if (-not (Test-Path $rs_sf)) { AddLog "warn" "settings.json not found - will create it." }
        SetLabel "Closing $rs_varName..."; SetProg 20
        Get-Process|Where-Object { $_.ProcessName -like "*discord*" }|Stop-Process -Force -EA SilentlyContinue
        Start-Sleep -Milliseconds 500; AddLog "ok" "$rs_varName closed"
        SetLabel "Writing settings.json..."; SetProg 55
        $settingsObj=[ordered]@{ SKIP_HOST_UPDATE=$true; DEVELOPER_MODE=$true; enableHardwareAcceleration=$false; MINIMIZE_TO_TRAY=$true; IS_MAXIMIZED=$true; OPEN_ON_STARTUP=$false; START_MINIMIZED=$false; IS_MINIMIZED=$false; debugLogging=$false }
        $json="{`n"; $keys=@($settingsObj.Keys)
        for ($i=0;$i -lt $keys.Count;$i++) {
            $k=$keys[$i]; $v=$settingsObj[$k]
            $jv=if ($v -is [bool]) { $v.ToString().ToLower() } else { $v.ToString().ToLower() }
            $comma=if ($i -lt $keys.Count-1) { "," } else { "" }
            $json+="  `"$k`": $jv$comma`n"; AddLog "ok" "$k = $jv"; SetProg (55+[int](($i+1)/$keys.Count*40))
        }
        $json+="}"
        try { [System.IO.File]::WriteAllText($rs_sf,$json); AddLog "ok" "Saved: $rs_sf" }
        catch { AddLog "err" "Write failed: $($_.Exception.Message)"; $rs_window.Dispatcher.Invoke([action]{ $rs_window.FindName("StBtnDoneGroup").Visibility="Visible" }); return }
        AddLog "ok" "$($keys.Count) settings written - restart Discord to apply."
        SetProg 100; SetLabel "Completed!" "#9ca3af"
        $tagVn2=$rs_varName; $tagKc2="$($keys.Count) settings written"
        $lKc=$tagKc2
        $rs_window.Dispatcher.Invoke([action]{
            $script:lastResult = @{ mb=$lKc; items=0; cancelled=$false }
            $rs_window.FindName("StBtnDoneGroup").Visibility="Visible"
        })
    })|Out-Null
    $handle=$ps.BeginInvoke(); Watch-RunspaceCompletion $ps $rs $handle
})

# =============================================================================
# CACHE OPERATION
# =============================================================================
$BtnCaRun.Add_Click({
    $doLocalStorage=$ChkLocalStorage.IsChecked; $variant=Get-SelectedVariant
    $prefs.localStorage=$doLocalStorage; Save-Prefs $prefs
    $script:lastResult = @{ mb=""; items=0; cancelled=$false }
    $CaBtnRunGroup.Visibility="Collapsed"; $CaBtnRunningGroup.Visibility="Visible"; $CaBtnDoneGroup.Visibility="Collapsed"
    $CaPage1Scroll.Visibility="Collapsed"; $CaPage2Scroll.Visibility="Visible"; $BtnCaStop.IsEnabled=$true
    $script:CaCts=[System.Threading.CancellationTokenSource]::new(); $token=$script:CaCts.Token
    $rs=[runspacefactory]::CreateRunspace(); $rs.ApartmentState="STA"; $rs.ThreadOptions="ReuseThread"; $rs.Open()
    $rs.SessionStateProxy.SetVariable("rs_window",$script:window)
    $rs.SessionStateProxy.SetVariable("rs_panel",$CaLogPanel); $rs.SessionStateProxy.SetVariable("rs_scroll",$CaLogScroll)
    $rs.SessionStateProxy.SetVariable("rs_fill",$CaProgressFill); $rs.SessionStateProxy.SetVariable("rs_pct",$CaProgressPct)
    $rs.SessionStateProxy.SetVariable("rs_label",$CaProgressLabel); $rs.SessionStateProxy.SetVariable("rs_token",$token)
    $rs.SessionStateProxy.SetVariable("rs_appdata",$variant.AppData); $rs.SessionStateProxy.SetVariable("rs_variantName",$variant.Name)
    $rs.SessionStateProxy.SetVariable("rs_doLocalStorage",$doLocalStorage)
    $rs.SessionStateProxy.SetVariable("RunspaceAddLogSB",$script:RunspaceAddLogSB)
    $ps=[powershell]::Create(); $ps.Runspace=$rs
    $ps.AddScript({
        function AddLog([string]$type,[string]$msg) { & $RunspaceAddLogSB -rs_type $type -rs_msg $msg -rs_panel_p $rs_panel -rs_scroll_p $rs_scroll -rs_window_p $rs_window }
        function SetProg([int]$v) {
            $rs_window.Dispatcher.Invoke([action]{
                $maxW=[math]::Max(100,$rs_fill.Parent.ActualWidth)
                $rs_fill.Width=[math]::Max(0,[math]::Min($maxW,$maxW*$v/100)); $rs_pct.Text="$v%"
            })
        }
        function SetLabel([string]$t,[string]$fg="") {
            $lt=$t; $lf=$fg
            $rs_window.Dispatcher.Invoke([action]{
                $rs_label.Text=$lt
                if ($lf -ne "") { $rs_label.Foreground=[Windows.Media.BrushConverter]::new().ConvertFrom($lf) }
            })
        }
        function Get-FolderSize($path) { if (-not (Test-Path $path)) { return 0 }; try { (Get-ChildItem $path -Recurse -Force -EA SilentlyContinue|Measure-Object -Property Length -Sum -EA SilentlyContinue).Sum } catch { 0 } }
        function Format-MB($b) { "$([math]::Round($b/1MB,2)) MB" }
        function CheckCancelled { if ($rs_token.IsCancellationRequested) { AddLog "warn" "Operation cancelled."; return $true }; return $false }
        $sw=[System.Diagnostics.Stopwatch]::StartNew(); $totalBytes=[ref]0L; $totalItems=0; $errorCount=0; $cancelled=$false
        if (-not (Test-Path $rs_appdata)) { AddLog "err" "AppData not found: $rs_appdata"; SetLabel "Error" "#ed4245"; return }
        SetLabel "Closing $rs_variantName..."; SetProg 5
        Get-Process|Where-Object { $_.ProcessName -like "*discord*" }|Stop-Process -Force -EA SilentlyContinue
        Start-Sleep -Milliseconds 600; AddLog "info" "$rs_variantName closed"
        $dirs=@("Cache","Code Cache","GPUCache","Cookies","Web Data","CacheStorage","ShaderCache","VideoDecodeStats","logs","Crashpad","debug","Databases","Session Storage","MediaFoundationWidevineCdm","sentry","shared_proto_db","WebStorage","WidevineCdm","blob_storage","component_crx_cache","DawnGraphiteCache","DawnWebGPUCache")
        $i=0
        foreach ($f in $dirs) {
            if (CheckCancelled) { $cancelled=$true; break }
            $i++; $pct=[int](10+($i/$dirs.Count)*80); SetLabel "Removing: $f"; SetProg $pct
            $p=Join-Path $rs_appdata $f
            if (Test-Path $p) { $size=Get-FolderSize $p; Remove-Item $p -Recurse -Force -EA SilentlyContinue; $totalBytes.Value+=$size; AddLog "ok" "$f  ($(Format-MB $size))"; $totalItems++ }
        }
        if (-not $cancelled -and (Test-Path "$rs_appdata\module_data\crashpad")) {
            $size=Get-FolderSize "$rs_appdata\module_data\crashpad"; Remove-Item "$rs_appdata\module_data\crashpad" -Recurse -Force -EA SilentlyContinue
            $totalBytes.Value+=$size; AddLog "ok" "module_data\crashpad  ($(Format-MB $size))"; $totalItems++
        }
        if (-not $cancelled -and $rs_doLocalStorage -and (Test-Path "$rs_appdata\Local Storage")) {
            $size=Get-FolderSize "$rs_appdata\Local Storage"; Remove-Item "$rs_appdata\Local Storage" -Recurse -Force -EA SilentlyContinue
            $totalBytes.Value+=$size; AddLog "warn" "Local Storage removed - re-login required  ($(Format-MB $size))"; $totalItems++
        }
        $sw.Stop(); SetProg 100
        if ($cancelled) { SetLabel "Cancelled" "#ed4245"; AddLog "warn" "Cancelled after $([int]$sw.Elapsed.TotalSeconds)s" }
        else {
            AddLog "ok" "Done in $([int]$sw.Elapsed.TotalSeconds)s - $totalItems items, $(Format-MB $totalBytes.Value) freed."
            SetLabel "Completed!" "#9ca3af"
        }
        $lMb3=Format-MB $totalBytes.Value; $lCan3=$cancelled; $lTi3=$totalItems
        $rs_window.Dispatcher.Invoke([action]{
            $script:lastResult = @{ mb=$lMb3; items=$lTi3; cancelled=$lCan3 }
            $r1=$rs_window.FindName("CaBtnRunningGroup"); $r2=$rs_window.FindName("CaBtnDoneGroup")
            if ($r1) { $r1.Visibility="Collapsed" }; if ($r2) { $r2.Visibility="Visible" }
        })
    })|Out-Null
    $handle=$ps.BeginInvoke(); Watch-RunspaceCompletion $ps $rs $handle
})

# =============================================================================
# STARTUP
# =============================================================================
$script:window.Add_Loaded({
    Apply-Prefs
    # Detect Discord Stable version only, update status bar
    $rs2=[runspacefactory]::CreateRunspace(); $rs2.Open()
    $ps2=[powershell]::Create(); $ps2.Runspace=$rs2
    $ps2.AddScript({
        param($w,$discordPath)
        Add-Type -AssemblyName PresentationFramework
        $highest=$null
        if (Test-Path $discordPath) {
            $highest=Get-ChildItem "$discordPath\app-*" -Directory -EA SilentlyContinue|
                Sort-Object { try { [System.Version]($_.Name.Substring(4)) } catch { [System.Version]"0.0" } }|
                Select-Object -Last 1
        }
        $verStr=if ($highest) { $highest.Name.Substring(4) } else { "not found" }
        $vStr = $verStr
        $w.Dispatcher.Invoke([action]{
            $sb=$w.FindName("StatusBarText2")
            $sd=$w.FindName("StatusDot")
            if ($sb) { $sb.Text="Discord  version: $vStr" }
            if ($sd) {
                $dotColor = if ($vStr -eq "not found") { "#ed4245" } else { "#23a559" }
                $sd.Fill = [Windows.Media.BrushConverter]::new().ConvertFrom($dotColor)
            }
        })

    })|Out-Null
    $ps2.AddArgument($script:window)|Out-Null
    $ps2.AddArgument("$env:LOCALAPPDATA\Discord")|Out-Null
    $handle2=$ps2.BeginInvoke()
    Watch-RunspaceCompletion $ps2 $rs2 $handle2
    Start-UpdateCheck
})

$script:window.ShowDialog()|Out-Null

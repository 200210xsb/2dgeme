// Place this file in Unity project path: Assets/Editor/BuildWindows.cs
using System.IO;
using UnityEditor;
using UnityEditor.Build.Reporting;

public static class BuildWindows
{
    public static void BuildGame()
    {
        string[] scenes = new[]
        {
            "Assets/Scenes/Main.unity"
        };

        string outputDir = "Builds/Windows";
        if (!Directory.Exists(outputDir))
        {
            Directory.CreateDirectory(outputDir);
        }

        string exePath = Path.Combine(outputDir, "SideScrollerFighter.exe");

        BuildPlayerOptions options = new BuildPlayerOptions
        {
            scenes = scenes,
            locationPathName = exePath,
            target = BuildTarget.StandaloneWindows64,
            options = BuildOptions.None
        };

        BuildReport report = BuildPipeline.BuildPlayer(options);
        if (report.summary.result != UnityEditor.Build.Reporting.BuildResult.Succeeded)
        {
            throw new BuildFailedException("Windows build failed");
        }
    }
}

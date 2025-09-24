{
  lib,
  mynixos,
  ...
}:
{
  config = lib.mkIf mynixos.rclone.enable {
    home.file.rclone_filter = {
      text = ''
        # Exclude
        - .obsidian/
        - .expo/
        - .svelte-kit/
        - target/debug/
        - .next/
        - node_modules/
        - dist/
        - lib/
        - bin/Debug/**
        - bin/Release/**
        - target/debug/**
        - target/release/**
        - logs/**

        # Include
        + /Documents/**
        + /Projects/**
        + /Resources/**
        + /.ssh/**

        # exclude everything else
        - *
      '';
      target = ".config/rclone/filter.txt";
    };
  };
}

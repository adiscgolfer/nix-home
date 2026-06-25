{ pkgs, ... }:

let
  llm = pkgs.writeShellApplication {
    name = "llm";
    runtimeInputs = [ pkgs.ollama ];
    text = ''
      case "''${1:-}" in
        start)
          if pgrep ollama > /dev/null 2>&1; then
            echo "ollama is already running (PID $(pgrep ollama))"
          else
            ollama serve > /tmp/ollama.log 2>&1 &
            echo "ollama started (PID $!)"
          fi
          ;;
        stop)
          if pgrep ollama > /dev/null 2>&1; then
            pkill ollama
            echo "ollama stopped"
          else
            echo "ollama is not running"
          fi
          ;;
        status)
          if pgrep ollama > /dev/null 2>&1; then
            echo "ollama is running (PID $(pgrep ollama))"
          else
            echo "ollama is not running"
          fi
          ;;
        *)
          echo "Usage: llm [start|stop|status]"
          exit 1
          ;;
      esac
    '';
  };
in
{
  home.packages = [
    pkgs.ollama
    llm
  ];
}

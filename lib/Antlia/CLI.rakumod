use Terminal::Boxer;

class Player is export {
    has Str $.name;
    has $.throw is rw;
    has $.score is rw = 0;
}

#| text based Rock paper scissors game
multi sub MAIN(
    Int :$players where * == 2 = 2, #= Number of players (default: 2)
) is export {
    say "Antlia - text based Rock paper scissors game";
    say "--------------------------------------------\n";

    my Player $player1 = Player.new(name => prompt("[Player 1] Name: ").trim);
    my Player $player2 = Player.new(name => prompt("[Player 2] Name: ").trim);

    my %ascii-art = (
        rock => %?RESOURCES<rock/2>.slurp,
        paper => %?RESOURCES<paper/2>.slurp,
        scissor => %?RESOURCES<scissor/2>.slurp,
    );

    my %score-against = (
        rock => "scissor",
        paper => "rock",
        scissor => "paper"
    );

    loop {
        print "\n";
        say "- " x 40;

        $player1.throw = %ascii-art.pick[0].key;
        $player2.throw = %ascii-art.pick[0].key;

        $player1.score += 1 if $player2.throw eq %score-against{$player1.throw};
        $player2.score += 1 if $player1.throw eq %score-against{$player2.throw};

        say ss-box(:40cw, %ascii-art{$player1.throw},
                   %ascii-art{$player2.throw});
        say ss-box(:40cw, "{$player1.name} ({$player1.score})",
                   "{$player2.name} ({$player2.score})");

        sink prompt "";
    }
}

multi sub MAIN(
    Bool :$version #= print version
) is export { say "Antlia v" ~ $?DISTRIBUTION.meta<version>; }

from ranger.gui.colorscheme import ColorScheme
from ranger.gui.color import bold, default, normal, reverse


class CatppuccinBase(ColorScheme):
    text = default
    base = default
    selection_bg = default
    surface1 = default
    blue = default
    teal = default
    green = default
    yellow = default
    mauve = default
    red = default
    overlay0 = default
    subtext0 = default
    progress_bar_color = default

    def use(self, context):  # pylint: disable=too-many-branches,too-many-statements
        fg, bg, attr = self.text, self.base, normal

        if context.reset:
            return fg, bg, attr

        if context.in_browser:
            if context.selected:
                attr = reverse | bold
                fg = self.base
                bg = self.selection_bg
            if context.empty or context.error:
                bg = self.red
            if context.border:
                fg = self.surface1
            if context.media:
                fg = self.yellow if context.image else self.mauve
            if context.container:
                fg = self.red
            if context.directory:
                attr |= bold
                fg = self.blue
            elif context.executable and not any((context.media, context.container, context.fifo, context.socket)):
                attr |= bold
                fg = self.green
            if context.socket:
                attr |= bold
                fg = self.mauve
            if context.fifo or context.device:
                fg = self.yellow
                if context.device:
                    attr |= bold
            if context.link:
                fg = self.teal if context.good else self.mauve
            if context.tag_marker and not context.selected:
                attr |= bold
                fg = self.red
            if not context.selected and (context.cut or context.copied):
                attr |= bold
                fg = self.overlay0
            if context.main_column:
                if context.marked:
                    attr |= bold
                    fg = self.yellow
            if context.badinfo:
                if attr & reverse:
                    bg = self.mauve
                else:
                    fg = self.mauve
            if context.inactive_pane:
                fg = self.subtext0

        elif context.in_titlebar:
            if context.hostname:
                fg = self.red if context.bad else self.green
            elif context.directory:
                fg = self.blue
            elif context.tab:
                if context.good:
                    bg = self.green
                    fg = self.base
            elif context.link:
                fg = self.teal
            attr |= bold

        elif context.in_statusbar:
            if context.permissions:
                if context.good:
                    fg = self.teal
                elif context.bad:
                    fg = self.mauve
            if context.marked:
                attr |= bold | reverse
                fg = self.yellow
                bg = self.base
            if context.frozen:
                attr |= bold | reverse
                fg = self.teal
                bg = self.base
            if context.message and context.bad:
                attr |= bold
                fg = self.red
            if context.loaded:
                bg = self.progress_bar_color
            if context.vcsinfo:
                fg = self.blue
                attr &= ~bold
            if context.vcscommit:
                fg = self.yellow
                attr &= ~bold
            if context.vcsdate:
                fg = self.teal
                attr &= ~bold

        if context.text and context.highlight:
            attr |= reverse

        if context.in_taskview:
            if context.title:
                fg = self.blue
            if context.selected:
                attr |= reverse
            if context.loaded:
                if context.selected:
                    fg = self.progress_bar_color
                else:
                    bg = self.progress_bar_color

        if context.vcsfile and not context.selected:
            attr &= ~bold
            if context.vcsconflict:
                fg = self.mauve
            elif context.vcsuntracked:
                fg = self.teal
            elif context.vcschanged or context.vcsunknown:
                fg = self.red
            elif context.vcsstaged or context.vcssync:
                fg = self.green
            elif context.vcsignored:
                fg = self.surface1
        elif context.vcsremote and not context.selected:
            attr &= ~bold
            if context.vcssync or context.vcsnone:
                fg = self.green
            elif context.vcsbehind:
                fg = self.red
            elif context.vcsahead:
                fg = self.blue
            elif context.vcsdiverged:
                fg = self.mauve
            elif context.vcsunknown:
                fg = self.red

        return fg, bg, attr

import PanelButton from "../PanelButton"



export default () => PanelButton({
    window: "languagemenu",
    on_clicked: action.bind(),
    child: Widget.Label({
        justification: "right",
        label: "SE", // TODO
    }),
})

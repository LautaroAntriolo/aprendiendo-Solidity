// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SubastaDebug {
    address public mejorPostor;
    uint256 public mejorApuesta;
    address payable public immutable VENDEDOR;
    uint256 public constant VALOR_INICIAL = 100;
    uint256 public immutable tiempoDeFinalizacion;

    mapping(address => uint256) public apostadores;

    error Subasta__NoEresElVendedor();
    error Subasta__ValorInsuficiente();
    error Subasta__MismoPostor();
    error Subasta__TiempoFinalizado();

    event SeHizoUnaApuestaNueva(address mejorApostador, uint256 mejorApuesta);
    event CambioDePrecio(uint256 precioViejo, uint256 precioNuevo);
    event Debug(string message, uint256 value);

    constructor(uint256 tiempoAdicional) { 
        VENDEDOR = payable(msg.sender); 
        tiempoDeFinalizacion = block.timestamp + tiempoAdicional;
        mejorApuesta = VALOR_INICIAL; 
    }
    // tiempoAdicional en el constructor. Este es un valor en segundos que determina cuánto durará la subasta.

    receive() external payable {
        hacerOferta();
    }
 
    fallback() external payable {
        hacerOferta();
    }

    function hacerOferta() public payable  {
        // Emitimos eventos de debug para cada check
        emit Debug("Valor enviado", msg.value);
        emit Debug("Mejor apuesta actual", mejorApuesta);
        emit Debug("Tiempo restante", tiempoDeFinalizacion - block.timestamp);

        if(msg.value <= mejorApuesta) {
            revert Subasta__ValorInsuficiente();
        }
        if(msg.sender == mejorPostor) {
            revert Subasta__MismoPostor();
        }
        if(block.timestamp >= tiempoDeFinalizacion) {
            revert Subasta__TiempoFinalizado();
        }
        
        if(mejorPostor != address(0) && address(this).balance > 0) {
            emit Debug("Devolviendo apuesta anterior", mejorApuesta);
            payable(mejorPostor).transfer(mejorApuesta);
            apostadores[mejorPostor] = 0;
        }

        apostadores[msg.sender] = msg.value;
        mejorApuesta = msg.value;
        mejorPostor = msg.sender;

        emit SeHizoUnaApuestaNueva(msg.sender, mejorApuesta);
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getTiempoRestante() public view returns (uint256) {
        if(block.timestamp >= tiempoDeFinalizacion) return 0;
        return tiempoDeFinalizacion - block.timestamp;
    }

    modifier soloDueno() {
        if(msg.sender != VENDEDOR) {
            revert Subasta__NoEresElVendedor();
        }
        _;
    }

    function cambiarPrecio(uint256 nuevoValor) public soloDueno {
        uint256 precioViejo = mejorApuesta;
        mejorApuesta = nuevoValor;
        emit CambioDePrecio(precioViejo, nuevoValor);
    }
}